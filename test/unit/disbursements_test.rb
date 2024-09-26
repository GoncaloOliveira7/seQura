# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('..', __dir__))

require 'models/disbursements'
require 'minitest/autorun'
require 'ostruct'

describe Disbursement do
  describe 'calculate_disbursement_range' do
    describe 'DAILY' do
      it 'applies same day range as orders created at' do
        subject = Disbursement.new(OpenStruct.new({
          'id' => 1,
          'reference' => 'reference',
          'email' => 'email',
          'live_on' => '2024-09-20',
          'disbursement_frequency' => 'DAILY',
          'minimum_monthly_fee' => 0
        }), 1)
        order = OpenStruct.new({ created_at: Date.parse('2024-09-24') })
        subject.calculate_disbursement_range(order)
        _(subject.start_date).must_equal Date.parse('2024-09-24')
        _(subject.end_date).must_equal Date.parse('2024-09-24')
      end
    end

    describe 'WEEKLY' do
      it 'calculates the correct week range' do
        subject = Disbursement.new(OpenStruct.new({
          'id' => 1,
          'reference' => 'reference',
          'email' => 'email',
          'live_on' => Date.parse('2023-05-20'),
          'disbursement_frequency' => 'WEEKLY',
          'minimum_monthly_fee' => 0
        }), 1)
        order = OpenStruct.new({ created_at: Date.parse('2024-09-24') })
        subject.calculate_disbursement_range(order)
        _(subject.start_date).must_equal Date.parse('2024-09-21')
        _(subject.end_date).must_equal Date.parse('2024-09-27')
        _(subject.start_date.wday).must_equal Date.parse('2024-09-21').wday
        _(subject.end_date.wday).must_equal Date.parse('2024-09-21').wday - 1
      end

      it 'calulates the correct week range if the live on and start date are in the same weekday' do
        subject = Disbursement.new(OpenStruct.new({
          'id' => 1,
          'reference' => 'reference',
          'email' => 'email',
          'live_on' => Date.parse('2023-05-16'),
          'disbursement_frequency' => 'WEEKLY',
          'minimum_monthly_fee' => 0
        }), 1)
        order = OpenStruct.new({ created_at: Date.parse('2024-09-24') })
        subject.calculate_disbursement_range(order)
        _(subject.start_date).must_equal Date.parse('2024-09-24')
        _(subject.end_date).must_equal Date.parse('2024-09-30')
        _(subject.start_date.wday).must_equal Date.parse('2024-09-24').wday
        _(subject.end_date.wday).must_equal Date.parse('2024-09-24').wday - 1
      end
    end

    describe 'invalid option' do
      it 'raises argument error' do
        subject = Disbursement.new(OpenStruct.new({
          'id' => 1,
          'reference' => 'reference',
          'email' => 'email',
          'live_on' => Date.parse('2023-05-16'),
          'disbursement_frequency' => 'INVALID',
          'minimum_monthly_fee' => 0
        }), 1)
        order = OpenStruct.new({ created_at: Date.parse('2024-09-24') })
        expect { subject.calculate_disbursement_range(order) }.must_raise ArgumentError
      end
    end
  end
end
