require 'services/create_disbursements_service'
require 'minitest/autorun'
require 'timecop'

describe CreateDisbursementsService do
  before do
    Timecop.freeze(Date.parse('2024-09-26'))
    @subject = CreateDisbursementsService.new(
      'tmp/disbursements.csv',
      'test/fixtures/merchants.csv',
      'test/fixtures/orders.csv'
    )
  end

  after do
    Timecop.return
  end

  describe 'perform' do
    it 'generates the correct report' do
      @subject.perform
      expected = File.open('test/fixtures/disbursements.csv')
      actual = File.open('tmp/disbursements.csv')

      _(expected.read).must_equal actual.read
    end
  end
end
