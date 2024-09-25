class Disbursement
  attr_reader :start_date, :end_date, :commission_fee, :disbursed_amount, :order_count

  attr_accessor :merchant

  def initialize(merchant)
    @merchant = merchant
    @commission_fee = 0
    @disbursed_amount = 0
    @order_count = 0
  end

  def calculate_disbursement_range(order)
    if @merchant.disbursement_frequency == 'DAILY'
      @start_date = order.created_at
      @end_date = order.created_at
    elsif @merchant.disbursement_frequency == 'WEEKLY'
      calculate_disbursement_weekly_range(order)
    else
      raise ArgumentError.new("Expected disbursement_frequency to be [DAILY, WEEKLY]: #{@merchant.disbursement_frequency}")
    end
  end

  def order_invalid?(order)
    order.created_at > @end_date || order.created_at < @start_date
  end

  def add_order(order)
    commission_fee = order.calculate_commission_fee
    @commission_fee += commission_fee
    @disbursed_amount += order.amount
    @order_count += 1
  end

  def create_csv_row(penalty_fee, start_of_the_month)
    [
      @merchant.reference,
      @disbursed_amount.to_f,
      @commission_fee.to_f,
      penalty_fee.to_f,
      @order_count,
      @start_date,
      @end_date,
      start_of_the_month
    ]
  end

  def calculate_penalty_fee(total_commission_fee)
    return 0 if total_commission_fee > @merchant.minimum_monthly_fee

    (@merchant.minimum_monthly_fee - total_commission_fee).round(2)
  end

  private

  def calculate_disbursement_weekly_range(order)
    @start_date = if @merchant.live_on.wday == order.created_at.wday
                    order.created_at
                  else
                    prior_weekday(order, Date::DAYNAMES[@merchant.live_on.wday])
                  end

    @end_date = @start_date + 6
  end

  def prior_weekday(order, weekday)
    weekday_index = Date::DAYNAMES.reverse.index(weekday)
    days_before = (order.created_at.wday + weekday_index) % 7 + 1
    order.created_at - days_before
  end
end
