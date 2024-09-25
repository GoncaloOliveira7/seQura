require 'bigdecimal'

class Order
  attr_accessor :id, :merchant_reference, :created_at

  attr_reader :amount

  def initialize(order)
    @id = order['id']
    @merchant_reference = order['merchant_reference']
    @amount = BigDecimal(order['amount'])
    @created_at = Date.parse(order['created_at'])
  end

  def calculate_commission_fee
    rate = if @amount < 50
             '0.01'
           elsif @amount >= 50 && @amount < 300
             '0.0095'
           else
             '0.0085'
           end

    (BigDecimal(rate) * @amount).round(2)
  end

  def amount=(amount)
    @amount = BigDecimal(amount)
  end
end
