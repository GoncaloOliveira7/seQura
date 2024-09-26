$LOAD_PATH.unshift(File.expand_path('..', __dir__))

require 'services/create_yearly_report_service'

CreateYearlyReportService.new(
  'data/disbursements.csv',
  'data/yearly_report.csv'
).perform
