require 'csv'
require 'pry'

HEADERS = %w[reference disbursed_sum commission_fee_sum penalty_fee_sum order_count start_date end_date ].freeze

def disbursement_frequency(start_date, end_date, date)
  start_date <= date && end_date >= date
end

def prior_weekday(date, weekday)
  weekday_index = Date::DAYNAMES.reverse.index(weekday)
  days_before = (date.wday + weekday_index) % 7 + 1
  date.to_date - days_before
end

def calculate_date_range(merchant, order)
  if merchant['disbursement_frequency'] == 'DAILY'
    [Date.parse(order['created_at']), Date.parse(order['created_at'])]
  else
    merchant_weekday = Date.parse(merchant['live_on']).wday
    order_weekday = Date.parse(order['created_at']).wday
    start_date = if merchant_weekday == order_weekday
                   Date.parse(order['created_at'])
                 else
                   prior_weekday(
                     Date.parse(order['created_at']), Date::DAYNAMES[merchant_weekday]
                   )
                 end
    end_date = start_date + 6
    [start_date, end_date]
  end
end

def calculate_fee(amount)
  amount = amount.to_f
  rate = if amount < 50
           0.01
         elsif amount >= 50 && amount < 300
           0.095
         else
           0.085
         end

  (rate * amount).ceil(2)
end

def calculate_cenas_fee(merchant, disbursed_monthly_amount, prev_end_date, end_date)
  return 0 if end_date.month <= prev_end_date.month

  disbursed_monthly_amount > merchant['minimum_monthly_fee'].to_f ? 0 : (disbursed_monthly_amount - merchant['minimum_monthly_fee'].to_f).abs
end

def do_report(merchant, disbursements, prev_end_date, order_fee_amount, disbursed_amount, disbursed_monthly_amount,
              order_count, start_date, end_date)

  disbursements << [
    merchant['reference'],
    order_fee_amount,
    disbursed_amount,
    disbursed_amount,
    order_count,
    start_date,
    end_date,
    calculate_cenas_fee(merchant, disbursed_monthly_amount, prev_end_date, end_date)
  ]

  if end_date.month > prev_end_date.month
    [disbursed_monthly_amount, prev_end_date]
  else
    [0, end_date]
  end
end

def run
  disbursements = CSV.open('../data/disbursements.csv', 'w', col_sep: ';', headers: HEADERS, write_headers: true)
  merchants = CSV.open('../data/merchants.csv', col_sep: ';', headers: true)
  merchant = merchants.shift
  order_fee_amount = 0
  disbursed_amount = 0
  disbursed_monthly_amount = 0
  order_count = 0
  first = true
  start_date = nil
  end_date = nil
  prev_end_date = nil
  
  CSV.foreach('../data/orders.csv', col_sep: ';', headers: true) do |order|
    if first
      first = false
      start_date, end_date = calculate_date_range(merchant, order)
      prev_end_date = end_date
    end

    if order['merchant_reference'] != merchant['reference']
      disbursed_monthly_amount, prev_end_date = do_report(merchant, disbursements, prev_end_date, order_fee_amount, disbursed_amount, disbursed_monthly_amount, order_count, start_date, end_date)
      start_date, end_date = calculate_date_range(merchant, order)
      merchant = merchants.shift
    end

    unless disbursement_frequency(start_date, end_date, Date.parse(order['created_at']))
      disbursed_monthly_amount, prev_end_date = do_report(merchant, disbursements, prev_end_date, order_fee_amount, disbursed_amount, disbursed_monthly_amount, order_count, start_date, end_date)
      start_date, end_date = calculate_date_range(merchant, order)
    end

    order_fee_amount += order['amount'].to_f
    disbursed_amount += calculate_fee(order['amount'])
    disbursed_monthly_amount += calculate_fee(order['amount'])
    order_count += 1
  end
end

run
