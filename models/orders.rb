class Order
  attr_reader :id, :merchant_reference, :amount, :created_at

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
end
