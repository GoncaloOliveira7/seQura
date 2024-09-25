require 'services/create_disbursement_report_service'
require 'minitest/autorun'

describe CreateDisbursementReportService do
  before do
    @subject = CreateDisbursementReportService.new(
      'tmp/disbursements.csv',
      'test/fixtures/merchants.csv',
      'test/fixtures/orders.csv'
    )
  end

  describe 'CreateDisbursementReportService' do
    it 'generates the correct report' do
      @subject.perform
      expected = File.open('test/fixtures/disbursements.csv')
      actual = File.open('tmp/disbursements.csv')

      _(expected.read).must_equal actual.read
    end
  end
end
