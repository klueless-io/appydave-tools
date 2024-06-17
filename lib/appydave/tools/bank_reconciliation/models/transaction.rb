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
                        :account_name,
                        :source_files

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
            @source_files = []
          end

          def add_source_file(source_file)
            @source_files << source_file.strip unless @source_files.include?(source_file.strip)
          end

          # cheque_number

          def self.csv_headers
            %i[
              platform
              account_name
              bsb_number
              account_number
              transaction_date
              narration
              debit
              credit
              balance
              transaction_type
              coa_code
              coa_match_type
              source_files
            ]
          end

          # @cheque_number,

          def to_csv_row
            [
              @platform,
              @account_name,
              @bsb_number,
              @account_number,
              @transaction_date,
              @narration,
              @debit,
              @credit,
              @balance,
              @transaction_type,
              @coa_code,
              @coa_match_type,
              @source_files
            ]
          end
        end
      end
    end
  end
end
