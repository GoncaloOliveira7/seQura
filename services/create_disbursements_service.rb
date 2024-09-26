require 'csv'
require 'models/orders'
require 'models/merchants'
require 'models/disbursements'

class CreateDisbursementsService
  HEADERS = %w[id merchant_reference disbursed_amount commission_fee penalty_fee_sum order_count start_date end_date new_month orders orders_fee order_amount
               ].freeze

  attr_accessor :order

  def initialize(disbursements_path, merchants_path, orders_path)
    @disbursements = CSV.open(disbursements_path, 'w', col_sep: ';', headers: HEADERS, write_headers: true)
    @merchants = CSV.open(merchants_path, col_sep: ';', headers: true)
    @merchant = Merchant.new(@merchants.shift)
    @order_path = orders_path
    @sequence = 0
    @disbursement = Disbursement.new(@merchant, @sequence)
    @monthly_commission_fee = 0
  end

  def perform
    puts 'Create Disbursement Report Service Started!'
    first_iteration = true
    CSV.foreach(@order_path, col_sep: ';', headers: true) do |order_row|
      @order = Order.new(order_row)

      if first_iteration
        first_iteration = false
        @disbursement.calculate_disbursement_range(@order)
        start_new_month
      end

      if @merchant.different_merchant?(@order)
        add_disbursement
        @merchant = Merchant.new(@merchants.shift)
        @disbursement.merchant = @merchant
        start_new_month
        reset_disbursement
      end

      if @disbursement.order_invalid?(@order)
        add_disbursement
        start_new_month if start_of_the_month?
        reset_disbursement
      end

      @disbursement.add_order(@order)
      @monthly_commission_fee += @order.calculate_commission_fee
    end

    add_disbursement if @disbursement.orders.size.positive?

    @disbursements.close
    puts 'Create Disbursement Report Service Finished!'
  end

  private

  def start_of_the_month?
    @disbursement.end_date.month > @prev_disbursement_end_date.month
  end

  def start_new_month
    @monthly_commission_fee = 0
    @prev_disbursement_end_date = @disbursement.end_date
  end

  def add_disbursement
    penalty_fee = start_of_the_month? ? @disbursement.calculate_penalty_fee(@monthly_commission_fee).to_f : 0
    @disbursements << @disbursement.create_csv_row(penalty_fee, start_of_the_month?)
  end

  def reset_disbursement
    @sequence += 1
    @disbursement = Disbursement.new(@merchant, @sequence)
    @disbursement.calculate_disbursement_range(@order)
  end
end
