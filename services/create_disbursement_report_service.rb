require 'csv'
require 'money'
require 'pry'
require 'models/orders'
require 'models/merchants'
require 'models/disbursements'

class CreateDisbursementReportService
  HEADERS = %w[reference disbursed_amount commission_fee penalty_fee_sum order_count start_date end_date].freeze

  attr_accessor :order

  def initialize
    root = File.expand_path('..', __dir__)
    @disbursements = CSV.open("#{root}/data/disbursements.csv", 'w', col_sep: ';',
                                                                     headers: HEADERS, write_headers: true)
    @merchants = CSV.open("#{root}/data/merchants.csv", col_sep: ';', headers: true)
    @merchant = Merchant.new(@merchants.shift)
    @order_path = "#{root}/data/orders.csv"
    @disbursement = Disbursement.new(@merchant)
    @monthly_commission_fee = 0
  end

  def perform
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
        @disbursement.calculate_disbursement_range(@order)
        start_new_month
        @merchant = Merchant.new(@merchants.shift)
      end

      if @disbursement.order_invalid?(order)
        add_disbursement
        @disbursement.calculate_disbursement_range(@order)
        start_new_month if start_of_the_month?
      end

      @disbursement.add_order(@order)
      @monthly_commission_fee += @order.calculate_commission_fee
    end
  end

  private

  def start_of_the_month?
    @disbursement.end_date.month <= @prev_disbursement_end_date.month
  end

  def start_new_month
    @monthly_commission_fee = 0
    @prev_disbursement_end_date = @disbursement.end_date
  end

  def add_disbursement
    penalty_fee = start_of_the_month? ? @disbursement.calculate_penalty_fee(@monthly_commission_fee).to_f : 0
    @disbursements << @disbursement.create_csv_row(penalty_fee)
  end
end
