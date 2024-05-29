# frozen_string_literal: true

module Appydave
  module Tools
    module BankReconciliation
      module Clean
        # Map transactions to chart of accounts and bank accounts
        class Mapper
          include Appydave::Tools::Configuration::Configurable

          # "bank_accounts": [
          #   {
          #     "account_number": "5435 6859 0116 7736",
          #     "bsb": "",
          #     "name": "Mastercard",
          #     "platform": "Bankwest"
          #   },
          #   {
          #     "account_number": "303-092",
          #     "bsb": "1361644",
          #     "name": "atcall",
          #     "platform": "Bankwest"
          #   },

          def map(transactions)
            transactions.map do |original_transaction|
              transaction = original_transaction.dup

              transaction = map_chart_of_account(transaction)
              map_bank_account(transaction)
            end
          end

          private

          def map_chart_of_account(transaction)
            equality_match(transaction) ||
              trigram_match(transaction, 0.9, '90%') ||
              trigram_match(transaction, 0.8, '80%') ||
              trigram_match(transaction, 0.7, '70%') ||
              trigram_match(transaction, 0.6, '60%') ||
              trigram_match(transaction, 0.5, '50%') ||
              transaction
          end

          def map_bank_account(transaction)
            bank_account = config.bank_reconciliation.get_bank_account(transaction.account_number, transaction.bsb_number)

            if bank_account
              transaction.account_name = bank_account.name
              transaction.platform = bank_account.platform
            end

            transaction
          end

          def equality_match(transaction)
            coa = config.bank_reconciliation.chart_of_accounts.find do |chart_of_account|
              chart_of_account.narration.to_s.delete(' ') == transaction.narration.delete(' ')
            end

            return nil unless coa

            transaction.coa_match_type = 'equality'
            transaction.coa_code = coa.code
            transaction
          end

          def trigram_match(transaction, score_threshold, match_type)
            scored_transactions = config.bank_reconciliation.chart_of_accounts.map do |coa|
              {
                coa: coa,
                score: compare(coa.narration, transaction.narration)
              }
            end

            scored_transactions.sort_by! { |t| t[:score] }.reverse!

            best = scored_transactions.first

            return nil unless best
            return nil if best[:score] < score_threshold

            coa = best[:coa]

            transaction.coa_match_type = match_type
            transaction.coa_code = coa.code
            transaction
          end

          def compare(text1, text2)
            text1_trigs = trigramify(text1)
            text2_trigs = trigramify(text2)

            all_cnt = (text1_trigs | text2_trigs).size
            same_cnt = (text1_trigs & text2_trigs).size

            same_cnt.to_f / all_cnt
          end

          def trigramify(text)
            trigs = []
            text.chars.each_cons(3) { |v| trigs << v.join }
            trigs
          end
        end
      end
    end
  end
end
