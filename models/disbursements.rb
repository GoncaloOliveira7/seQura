class Disbursement
  attr_reader :start_date, :end_date, :orders

  attr_accessor :merchant

  def initialize(merchant, sequence)
    @merchant = merchant
    @sequence = sequence
    @orders = []
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
    @orders << order
  end

  def create_csv_row(penalty_fee, start_of_the_month)
    [
      uniq_identifier,
      @merchant.reference,
      @orders.sum(&:amount).to_f,
      @orders.sum(&:calculate_commission_fee).to_f,
      penalty_fee.to_f,
      @orders.size,
      @start_date,
      @end_date,
      start_of_the_month,
      @orders.map(&:id).join(' '),
      @orders.map { |o| o.calculate_commission_fee.to_f }.join(' '),
      @orders.map { |o| o.amount.to_f }.join(' ')
    ]
  end

  def calculate_penalty_fee(total_commission_fee)
    return 0 if total_commission_fee > @merchant.minimum_monthly_fee

    (@merchant.minimum_monthly_fee - total_commission_fee).round(2)
  end

  private

  def uniq_identifier
    (Time.now.to_i.to_s + @sequence.to_s.rjust(6, '0')).to_i.to_s(32)
  end

  def calculate_disbursement_weekly_range(order)
    @start_date = if @merchant.live_on.wday == order.created_at.wday
                    order.created_at
                  else
                    prior_weekday(order)
                  end

    @end_date = @start_date + 6
  end

  def prior_weekday(order)
    days_before = (order.created_at.wday + (7 - @merchant.live_on.wday)) % 7
    order.created_at - days_before
  end
end


