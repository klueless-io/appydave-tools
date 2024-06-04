# frozen_string_literal: true

module Appydave
  module Tools
    module BankReconciliation
      module Clean
        # Read transactions from a CSV file
        class ReadTransactions
          attr_reader :platform
          attr_reader :transactions

          def initialize(file)
            @file = file
          end

          def read
            csv_lines = File.read(@file).lines

            @platform = detect_platform(csv_lines)

            case platform
            when :bankwest
              read_bankwest(csv_lines)
            when :bankwest2
              read_bankwest2(csv_lines)
            end
          end

          private

          def read_bankwest(csv_lines)
            @transactions = []

            # Skip the header line and parse each subsequent line
            CSV.parse(csv_lines.join, headers: true).each do |row|
              transaction = Models::Transaction.new(
                bsb_number: row['BSB Number'],
                account_number: row['Account Number'],
                transaction_date: row['Transaction Date'],
                narration: row['Narration'],
                cheque_number: row['Cheque Number'],
                debit: row['Debit'],
                credit: row['Credit'],
                balance: row['Balance'],
                transaction_type: row['Transaction Type']
              )
              @transactions << transaction
            end

            @transactions
          end

          def read_bankwest2(csv_lines)
            @transactions = []

            # Skip the header line and parse each subsequent line
            CSV.parse(csv_lines.join, headers: true).each do |row|
              transaction = Models::Transaction.new(
                bsb_number: row['BSB / Account Number'].split(' - ').first,
                account_number: row['BSB / Account Number'].split(' - ').last,
                transaction_date: row['Transaction Date'],
                narration: row['Narration'],
                cheque_number: row['Cheque Number'],
                debit: row['Debit'],
                credit: row['Credit'],
                balance: row['Balance'],
                transaction_type: row['Transaction Type']
              )
              @transactions << transaction
            end

            @transactions
          end

          # For bankwest the first row is the CSV will look like:
          # BSB Number,Account Number,Transaction Date,Narration,Cheque Number,Debit,Credit,Balance,Transaction Type
          def detect_platform(csv_lines)
            return :bankwest if csv_lines.first.start_with?('BSB Number,Account Number,Transaction Date,Narration,Cheque Number,Debit,Credit,Balance,Transaction Type')
            return :bankwest2 if csv_lines.first.start_with?('Account Name,BSB / Account Number,Transaction Date,Narration,Cheque Number,Debit,Credit,Balance,Transaction Type')

            puts "Unknown platform detected. CSV columns are: #{csv_lines.first.strip}"
            raise Appydave::Tools::Error, 'Unknown platform'
          end
        end
      end
    end
  end
end
