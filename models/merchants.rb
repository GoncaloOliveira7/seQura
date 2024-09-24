class Merchant
  attr_reader :id, :reference, :email, :live_on, :disbursement_frequency, :minimum_monthly_fee

  def initialize(merchant)
    @id = merchant['id']
    @reference = merchant['reference']
    @email = merchant['email']
    @live_on = Date.parse(merchant['live_on'])
    @disbursement_frequency = merchant['disbursement_frequency']
    @minimum_monthly_fee = BigDecimal(merchant['minimum_monthly_fee'])
  end

  def different_merchant?(order)
    @reference != order.merchant_reference
  end
end
