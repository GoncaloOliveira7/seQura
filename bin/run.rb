# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('..', __dir__))

require 'services/create_disbursement_report_service'

CreateDisbursementReportService.new(
  'data/disbursements.csv',
  'data/merchants.csv',
  'data/orders.csv'
).perform
