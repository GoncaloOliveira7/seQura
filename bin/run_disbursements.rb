$LOAD_PATH.unshift(File.expand_path('..', __dir__))

require 'services/create_disbursements_service'

CreateDisbursementsService.new(
  'data/disbursements.csv',
  'data/merchants.csv',
  'data/orders.csv'
).perform
