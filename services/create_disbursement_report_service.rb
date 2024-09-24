require 'csv'
require 'bigdecimal'

class CreateDisbursementReportService
  HEADERS = %w[reference disbursed_amount commission_fee penalty_fee_sum order_count start_date end_date].freeze

  attr_accessor :disbursements, :merchants, :merchant, :order_path, :disbursed_amount, :commission_fee,
                :monthly_commission_fee, :order_count

  def initialize
    @disbursements = CSV.open('../data/disbursements.csv', 'w', col_sep: ';', headers: HEADERS, write_headers: true)
    @merchants = CSV.open('../data/merchants.csv', col_sep: ';', headers: true)
    @merchant = @merchants.shift
    @order_path = '../data/orders.csv'

    @disbursed_amount = 0
    @commission_fee = 0
    @monthly_commission_fee = 0
    @order_count = 0
  end

  def disbursement_in_range?
    @disbursement_start <= @order_date && @disbursement_end >= @order_date
  end

  def prior_weekday(weekday)
    weekday_index = Date::DAYNAMES.reverse.index(weekday)
    days_before = (@order_date.wday + weekday_index) % 7 + 1
    @order_date - days_before
  end

  def calculate_disbursement_range
    if @merchant['disbursement_frequency'] == 'DAILY'
      @disbursement_start = @order_date
      @disbursement_end = @order_date
    else
      calculate_disbursement_weekly_range
    end
  end

  def calculate_disbursement_weekly_range
    merchant_weekday = Date.parse(@merchant['live_on']).wday
    order_weekday = @order_date.wday
    @disbursement_start = if merchant_weekday == order_weekday
                            @order_date
                          else
                            prior_weekday(
                              Date::DAYNAMES[merchant_weekday]
                            )
                          end
    @disbursement_end = @disbursement_start + 6
  end

  def calculate_commission_fee
    amount = BigDecimal(@order['amount'])
    rate = if amount < 50
             '0.01'
           elsif amount >= 50 && amount < 300
             '0.095'
           else
             '0.085'
           end

    (BigDecimal(rate) * amount)
  end

  def start_of_the_month?
    @disbursement_end.month <= @prev_disbursement_end.month
  end

  def calculate_penalty_fee
    minimum_monthly_fee = BigDecimal(@merchant['minimum_monthly_fee'])
    return 0 if @monthly_commission_fee > minimum_monthly_fee

    (@monthly_commission_fee - minimum_monthly_fee).round(2)
  end

  def start_new_month
    @monthly_commission_fee = 0
    @prev_disbursement_end = @disbursement_end
  end

  def add_disbursement
    @disbursements << [
      @merchant['reference'],
      @disbursed_amount.round(2).to_f,
      @commission_fee.round(2).to_f,
      start_of_the_month? ? calculate_penalty_fee.to_f : 0,
      @order_count,
      @disbursement_start,
      @disbursement_end
    ]
  end

  def new_merchant?
    @order['merchant_reference'] != @merchant['reference']
  end

  def add_order
    commission_fee = calculate_commission_fee
    @commission_fee += commission_fee
    @monthly_commission_fee += commission_fee
    @disbursed_amount += BigDecimal(@order['amount'])
    @order_count += 1
  end

  def perform
    first_iteration = true
    CSV.foreach(@order_path, col_sep: ';', headers: true) do |order|
      @order = order
      @order_date = Date.parse(order['created_at'])

      if first_iteration
        first_iteration = false
        calculate_disbursement_range
        start_new_month
      end

      if new_merchant?
        add_disbursement
        calculate_disbursement_range
        start_new_month
        @merchant = @merchants.shift
      end

      unless disbursement_in_range?
        add_disbursement
        calculate_disbursement_range
        start_new_month if start_of_the_month?
      end

      add_order
    end
  end
end

DisbursementService.new.perform
