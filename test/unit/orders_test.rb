$LOAD_PATH.unshift(File.expand_path('..', __dir__))

require 'models/orders'
require 'minitest/autorun'

describe Order do
  before do
    @subject = Order.new({ 'id' => 1, 'merchant_reference' => 'merchant_reference', 'amount' => 0, 'created_at' => '2024-10-01' })
  end

  describe 'calculate_commission_fee' do
    it 'applies 1% commission fee to amounts greater than 0 and less than 50' do
      @subject.amount = 49
      _(@subject.calculate_commission_fee.to_f).must_equal 0.49
      @subject.amount = 10
      _(@subject.calculate_commission_fee.to_f).must_equal 0.1
    end

    it 'applies 0.95% commission fee to amounts greater or equal to 50 and less than 300' do
      @subject.amount = 50
      _(@subject.calculate_commission_fee.to_f).must_equal 0.48
      @subject.amount = 299
      _(@subject.calculate_commission_fee.to_f).must_equal 2.84
    end

    it 'applies 0.95% commission fee to amounts greater or equal to 50 and less than 300' do
      @subject.amount = 300
      _(@subject.calculate_commission_fee.to_f).must_equal 2.55
    end
  end
end
