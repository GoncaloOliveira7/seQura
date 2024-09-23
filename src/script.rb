require 'csv'
require 'pry'

binding.pry

HEADERS = %w[reference disbursed_amount fee_amount order_count]

def disbursement_frequency(start_date, merchant, order)
  if merchant['disbursement_frequency'] == 'DAILY'
    start_date == order['created_at']
  else
    Date.parse(start_date).cweek == Date.parse(order['created_at']).cweek
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

# def prev_weekday_date(date, weekday)
#   aux = Date.parse(date)
#   while aux.wday != weekday
#     aux - 1
#   end
#   aux.to_s
# end
#

def run
  CSV.open('../data/disbursements.csv', 'w', col_sep: ';', headers: HEADERS, write_headers: true) do |disbursements|
    merchants = CSV.open('../data/merchants_demo.csv', col_sep: ';', headers: true)
    merchant = merchants.shift
    orders = CSV.open('../data/orders_demo.csv', col_sep: ';', headers: true)
    order = orders.shift
    first_month_date = order['created_at']

    while order
      merchant = merchants.shift if merchant['reference'] != order['merchant_reference']
      start_date = order['created_at']
      disbursed_amount = 0
      fee_amount = 0
      order_count = 0
      

      month_disbursed_amount = 0

      while order && disbursement_frequency(start_date, merchant, order)
        fee_amount += order['amount'].to_f
        disbursed_amount += calculate_fee(order['amount'])
        month_disbursed_amount += calculate_fee(order['amount'])
        order_count += 1

        order = orders.shift
      end

      puts '#################################################'
      puts merchant['reference']
      puts fee_amount.ceil(2)
      puts disbursed_amount.ceil(2)
      puts order_count
      puts '#################################################'
      disbursements << [merchant['reference'], fee_amount.ceil(2), disbursed_amount.ceil(2), disbursed_amount.ceil(2), order_count]
    end
  end
end

run

# File.open('../data/disbursements.csv') do |disbursements|

#   CSV.foreach('../data/orders_demo.csv', col_sep: ';', headers: true) do |order|
#     # if order['reference'] != merchant['reference']
#     #   merchant = merchants.shift

#     # end

#     if merchant['disbursement_frequency'] == 'DAILY'
#       bach
#     end

#   end

#   CSV.table(file)
# end
