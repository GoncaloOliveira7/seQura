$LOAD_PATH.unshift(File.expand_path('..', __dir__))

require 'services/create_disbursement_report_service'
require 'minitest/autorun'
require 'pry'

describe CreateDisbursementReportService do
  before do
    @subject = CreateDisbursementReportService.new
  end

  describe 'calculate_commission_fee' do
    it 'applies 1% commission fee to amounts greater than 0 and less than 50' do
      @subject.order = { 'amount' => '49' }
      _(@subject.calculate_commission_fee.to_f).must_equal 0.49
      @subject.order = { 'amount' => '10' }
      _(@subject.calculate_commission_fee.to_f).must_equal 0.1
    end

    it 'applies 0.95% commission fee to amounts greater or equal to 50 and less than 300' do
      @subject.order = { 'amount' => '50' }
      _(@subject.calculate_commission_fee.to_f).must_equal 0.48
      @subject.order = { 'amount' => '299' }
      _(@subject.calculate_commission_fee.to_f).must_equal 2.84
    end

    it 'applies 0.95% commission fee to amounts greater or equal to 50 and less than 300' do
      @subject.order = { 'amount' => '300' }
      _(@subject.calculate_commission_fee.to_f).must_equal 2.55
    end
  end
end
