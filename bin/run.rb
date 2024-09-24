#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.expand_path('..', __dir__))

require 'services/create_disbursement_report_service'

CreateDisbursementReportService.new.perform
