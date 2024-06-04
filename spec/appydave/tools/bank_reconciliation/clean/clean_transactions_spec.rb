# frozen_string_literal: true

# 303-111,1234567,12/12/2023,"Capital Transfer",,-50.00,,0.50,TFD
# 303-222,1234567,11/12/2023,"Money going out",,,70,70.50,DEP
# 303-333,1234567,04/12/2023,"Money comming in",,,12,999,DEP

RSpec.describe Appydave::Tools::BankReconciliation::Clean::CleanTransactions do
  let(:instance) { described_class.new(transaction_folder: transaction_folder) }
  let(:transaction_folder) { 'spec/fixtures/bank-reconciliation' }
  let(:input_globs) { ['bank-west.csv'] }
  let(:temp_folder) { Dir.mktmpdir }
  let(:output_file) { File.join(temp_folder, 'output.csv') }
  let(:config_file) { File.join(temp_folder, 'bank-reconciliation.json') }
  let(:config_data) do
    {
      chart_of_accounts: [
        { 'code' => 'Transfer', 'narration' => 'Capital Transfer' },
        { 'code' => 'Expense', 'narration' => 'Money going >' },
        { 'code' => 'Income', 'narration' => 'Money comming <' }
      ],
      bank_accounts: [
        { 'account_number' => '1234567', 'bsb' => '303-111', 'name' => 'Test Account 1', 'platform' => 'Test Bank' },
        { 'account_number' => '1234567', 'bsb' => '303-222', 'name' => 'Test Account 2', 'platform' => 'Test Bank' },
        { 'account_number' => '1234567', 'bsb' => '303-333', 'name' => 'Test Account 3', 'platform' => 'Another Bank' }
      ]
    }
  end

  before do
    File.write(config_file, config_data.to_json)

    Appydave::Tools::Configuration::Config.configure do |config|
      config.config_path = temp_folder
      config.register(:bank_reconciliation, Appydave::Tools::Configuration::Models::BankReconciliationConfig)
    end
  end

  after do
    FileUtils.remove_entry(temp_folder)
  end

  context 'when grabing transactions from file' do
    it 'reads transaction from file' do
      raw_transactions = instance.send(:grab_raw_transactions, input_globs)
      expect(raw_transactions.size).to eq(3)
    end
  end

  context 'when duplicate transactions in single file' do
    it 'duplicates and reports duplicate count' do
      sample_transactions = (1..4).map do
        Appydave::Tools::BankReconciliation::Models::Transaction.new(
          bsb_number: '303-111',
          account_number: '1234567',
          transaction_date: '12/12/2023'
        )
      end

      transactions, duplicate_count = instance.send(:deduplicate, sample_transactions)

      expect(transactions.size).to eq(1)
      expect(duplicate_count).to eq(3)
    end
  end

  # describe '.clean_transactions' do
  #   before { instance.clean_transactions(input_globs, output_file) }

  #   context 'when file has no duplicates' do
  #     subject { instance.transactions.size }

  #     it { is_expected.to eq(3) }
  #   end

  #   context 'when file has duplicates' do
  #     subject { instance.transactions.size }

  #     let(:input_globs) { ['bank-west-has-duplicates.csv'] }

  #     it { is_expected.to eq(2) }
  #   end

  #   context 'when transaction #1 mappings' do
  #     subject { instance.transactions[0] }

  #     it { is_expected.to have_attributes(coa_match_type: 'equality', coa_code: 'Transfer', account_name: 'Test Account 1', platform: 'Test Bank') }
  #   end

  #   context 'when transaction #2 mappings' do
  #     subject { instance.transactions[1] }

  #     it { is_expected.to have_attributes(coa_match_type: '70%', coa_code: 'Expense', account_name: 'Test Account 2', platform: 'Test Bank') }
  #   end

  #   context 'when transaction #3 mappings' do
  #     subject { instance.transactions[2] }

  #     it { is_expected.to have_attributes(coa_match_type: '80%', coa_code: 'Income', account_name: 'Test Account 3', platform: 'Another Bank') }
  #   end
  # end
end
