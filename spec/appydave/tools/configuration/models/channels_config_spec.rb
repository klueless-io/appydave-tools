# frozen_string_literal: true

# "locations": {
#   "content_projects": "/Users/davidcruwys/Library/CloudStorage/Dropbox/team-aitldr",
#   "video_projects": "/Volumes/Expansion/Sync/tube-channels/aitldr/active",
#   "published_projects": "/Volumes/Expansion/content-archive/4brand/published/aitldr",
#   "abandoned_projects": "/Volumes/Expansion/content-archive/4brand/failed/aitldr"
# }

RSpec.describe Appydave::Tools::Configuration::Models::ChannelsConfig do
  let(:temp_folder) { Dir.mktmpdir }
  let(:channels_config) { described_class.new }
  let(:config_file) { File.join(temp_folder, 'channels.json') }
  let(:config_data) do
    {
      'channels' => {
        'appydave' => {
          'code' => 'ad',
          'name' => 'AppyDave',
          'youtube_handle' => '@appydave',
          'locations' => {
            'content_projects' => 'path/content/appydave',
            'video_projects' => 'path/video/appydave',
            'published_projects' => 'path/published/appydave',
            'abandoned_projects' => 'path/abandoned/appydave'
          }
        },
        'appydave_coding' => {
          'code' => 'ac',
          'name' => 'AppyDave Coding',
          'youtube_handle' => '@appydavecoding',
          'locations' => {
            'content_projects' => 'path/content/appydave_coding',
            'video_projects' => 'path/video/appydave_coding',
            'published_projects' => 'path/published/appydave_coding',
            'abandoned_projects' => 'path/abandoned/appydave_coding'
          }
        }
      }
    }
  end

  before do
    File.write(config_file, config_data.to_json)
    Appydave::Tools::Configuration::Config.configure do |config|
      config.config_path = temp_folder
    end
  end

  after do
    FileUtils.remove_entry(temp_folder)
  end

  describe '#initialize' do
    describe '.name' do
      subject { channels_config.name }

      it { is_expected.to eq('Channels') }
    end

    describe '.config_name' do
      subject { channels_config.config_name }

      it { is_expected.to eq('channels') }
    end

    describe '.config_path' do
      subject { channels_config.config_path }

      it { is_expected.to eq(config_file) }
    end

    describe '.data' do
      subject { channels_config.data }

      it { is_expected.to eq(config_data) }
    end
  end

  describe '#get_channel' do
    it 'retrieves existing channel information by string code' do
      channel = channels_config.get_channel('appydave')

      expect(channel.name).to eq('AppyDave')
      expect(channel.youtube_handle).to eq('@appydave')
    end

    it 'retrieves existing channel information by symbol code' do
      channel = channels_config.get_channel(:appydave)

      expect(channel.name).to eq('AppyDave')
      expect(channel.youtube_handle).to eq('@appydave')
    end

    it 'returns default channel information for a non-existent channel' do
      channel = channels_config.get_channel('nonexistent_channel')

      expect(channel.name).to eq('')
      expect(channel.youtube_handle).to eq('')
    end

    describe '.locations' do
      it 'retrieves existing channel locations' do
        channel = channels_config.get_channel('appydave')

        expect(channel.locations.content_projects).to eq('path/content/appydave')
        expect(channel.locations.video_projects).to eq('path/video/appydave')
        expect(channel.locations.published_projects).to eq('path/published/appydave')
        expect(channel.locations.abandoned_projects).to eq('path/abandoned/appydave')
      end
    end
  end

  describe '#set_channel' do
    let(:new_channel) do
      Appydave::Tools::Configuration::Models::ChannelsConfig::ChannelInfo.new('some_key',
                                                                              'code' => 'nc',
                                                                              'name' => 'New Channel',
                                                                              'youtube_handle' => '@newchannel')
    end

    it 'sets new channel information and persists it' do
      channels_config.set_channel('nc', new_channel)
      channels_config.save

      reloaded_channels_config = described_class.new
      reloaded_channel = reloaded_channels_config.get_channel('nc')

      expect(reloaded_channel.name).to eq('New Channel')
      expect(reloaded_channel.youtube_handle).to eq('@newchannel')
    end
  end

  describe '#key?' do
    it 'returns true for an existing channel code' do
      expect(channels_config.key?('appydave')).to be true
    end
  end

  describe '#code?' do
    it 'returns true for an existing channel code' do
      expect(channels_config.code?('appydave')).to be false
      expect(channels_config.code?('ac')).to be true
    end
  end

  describe '#channels' do
    let(:channels_config) { described_class.new }

    it 'returns a list of all channels' do
      channels = channels_config.channels
      expect(channels.size).to eq(2)
      expect(channels.first.name).to eq('AppyDave')
      expect(channels.first.youtube_handle).to eq('@appydave')
      expect(channels.last.name).to eq('AppyDave Coding')
      expect(channels.last.youtube_handle).to eq('@appydavecoding')
    end
  end
end
