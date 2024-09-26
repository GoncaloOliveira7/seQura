require 'csv'

class CreateYearlyReportService
  HEADERS = %w[year disbursement_count disbursements_amount disbursements_fee monthy_penalty_fee_count
               disbursements_penalty_fee].freeze

  attr_accessor :order

  def initialize(disbursements_path, yearly_report_path)
    @disbursements_path = disbursements_path
    @yearly_reports_csv = CSV.open(yearly_report_path, 'w', col_sep: ';', headers: HEADERS, write_headers: true)
  end

  def perform
    yearly_reports = {}
    puts 'Create Yearly Report Service Started!'

    CSV.foreach(@disbursements_path, col_sep: ';', headers: true) do |disbursement|
      year = Date.parse(disbursement['start_date']).year
      yearly_report = yearly_reports[Date.parse(disbursement['start_date']).year]
      if yearly_report
        yearly_report['year'] = year
        yearly_report['disbursement_count'] += 1
        yearly_report['disbursements_amount'] += BigDecimal(disbursement['disbursed_amount'])
        yearly_report['disbursements_fee'] += BigDecimal(disbursement['commission_fee'])
        if disbursement['new_month'] == 'true' && disbursement['penalty_fee_sum'].to_i.positive?
          yearly_report['monthy_penalty_fee_count'] += 1
        end
        yearly_report['disbursements_penalty_fee'] += BigDecimal(disbursement['penalty_fee_sum'])
      else
        yearly_reports[year] = {
          'year' => year,
          'disbursement_count' => 1,
          'disbursements_amount' => BigDecimal(disbursement['disbursed_amount']),
          'disbursements_fee' => BigDecimal(disbursement['commission_fee']),
          'monthy_penalty_fee_count' => disbursement['new_month'] == 'true' && disbursement['penalty_fee_sum'].to_i.positive? ? 1 : 0,
          'disbursements_penalty_fee' => BigDecimal(disbursement['penalty_fee_sum'])
        }
      end
    end

    yearly_reports.each_value do |year|
      @yearly_reports_csv << [
        year['year'],
        year['disbursement_count'],
        year['disbursements_amount'].to_f,
        year['disbursements_fee'].to_f,
        year['monthy_penalty_fee_count'],
        year['disbursements_penalty_fee'].to_f
      ]
    end

    @yearly_reports_csv.close

    puts 'Create Yearly Report Service Finished!'
  end
end
