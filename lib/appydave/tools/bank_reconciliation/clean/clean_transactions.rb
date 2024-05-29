# frozen_string_literal: true

module Appydave
  module Tools
    module BankReconciliation
      module Clean
        # Clean transactions
        class CleanTransactions
          include Appydave::Tools::Configuration::Configurable
          include KLog::Logging

          attr_reader :transaction_folder
          attr_reader :transactions

          # (config_file)
          def initialize(transaction_folder: '/Volumes/Expansion/Sync/bank-reconciliation/original-transactions')
            @transaction_folder = transaction_folder
          end

          def clean_transactions(input_globs, _output_file)
            raw_transactions = grab_raw_transactions(input_globs)
            transactions, duplicates_count = deduplicate(raw_transactions)

            transactions = Mapper.new.map(transactions)
            # tp transactions

            log.kv 'Deduped consolidated transactions', duplicates_count if duplicates_count.positive?

            # transactions = normalize(transactions)
            # save_to_csv(transactions, output_file)
            @transactions = transactions
          end

          private

          def grab_raw_transactions(input_globs)
            original_dir = Dir.pwd
            transactions = []

            begin
              Dir.chdir(transaction_folder)

              input_globs.each do |glob|
                Dir.glob(glob).each do |file|
                  raw_transactions = ReadTransactions.new(file).read
                  deduped_transactions, duplicates_count = deduplicate(raw_transactions)

                  if duplicates_count.positive?
                    log.kv 'Duplicates count', duplicates_count
                    log.kv 'File', file
                  end

                  transactions += deduped_transactions
                end
              end
            ensure
              Dir.chdir(original_dir)
            end

            transactions
          end

          def deduplicate(transactions)
            unique_transactions = transactions.uniq do |transaction|
              [
                transaction.bsb_number,
                transaction.account_number,
                transaction.transaction_date,
                transaction.narration,
                transaction.cheque_number,
                transaction.debit,
                transaction.credit,
                transaction.balance,
                transaction.transaction_type
              ]
            end

            duplicates = transactions.size - unique_transactions.size

            [unique_transactions, duplicates]
          end

          def save_to_csv(transactions, output_file)
            CSV.open(output_file, 'w') do |csv|
              csv << ReconciledTransaction.csv_headers
              transactions.each do |transaction|
                csv << transaction.to_csv_row
              end
            end
          end
        end
      end
    end
  end
end
