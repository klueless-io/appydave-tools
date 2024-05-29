# frozen_string_literal: true

module Appydave
  module Tools
    module BankReconciliation
      module Models
        # Unified transaction model for raw and reconciled data
        class Transaction
          attr_accessor :bsb_number,
                        :account_number,
                        :transaction_date,
                        :narration,
                        :cheque_number,
                        :debit,
                        :credit,
                        :balance,
                        :transaction_type,
                        :platform,
                        :coa_code,
                        :coa_match_type,
                        :account_name

          def initialize(bsb_number: nil,
                         account_number: nil,
                         transaction_date: nil,
                         narration: nil,
                         cheque_number: nil,
                         debit: nil,
                         credit: nil,
                         balance: nil,
                         transaction_type: nil,
                         platform: nil,
                         coa_code: nil,
                         coa_match_type: nil,
                         account_name: nil)
            @bsb_number = bsb_number&.strip
            @account_number = account_number&.strip
            @transaction_date = transaction_date&.strip
            @transaction_date = Date.strptime(@transaction_date, '%d/%m/%Y')
            @narration = narration&.gsub(/\s{2,}/, ' ')&.strip
            @cheque_number = cheque_number&.strip
            @debit = debit&.strip
            @credit = credit&.strip
            @balance = balance&.strip
            @transaction_type = transaction_type&.strip
            @platform = platform
            @coa_code = coa_code
            @coa_match_type = coa_match_type
            @account_name = account_name
          end
        end
      end
    end
  end
end
