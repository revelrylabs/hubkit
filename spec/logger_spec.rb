require 'spec_helper'

describe Hubkit::Logger do
  before(:each) do
    Hubkit::Logger.instance_variable_set(:@_inner_logger, nil)
  end

  it 'should delegate down to inner logger' do
    severities = Logger::Severity.constants.map(&:to_s).map(&:downcase)
    logger_methods = Hash[severities.map { |s| [s, nil] }]

    allow(Hubkit::Logger).to receive(:inner_logger).and_return(double('mock logger', logger_methods))

    severities.each do |severity|
      Hubkit::Logger.send(severity, 'test log')
    end

    severities.each do |severity|
      expect(Hubkit::Logger.inner_logger).to have_received(severity).with(/HUBKIT/)
    end
  end

  describe '#inner_logger' do
    context 'with rails' do
      it 'uses Rails logger' do
        mock_rails = Hashie::Mash.new logger: true
        stub_const('Rails', mock_rails)

        expect(Hubkit::Logger.inner_logger).to eq mock_rails.logger
      end
    end

    context 'without rails' do
      it 'uses a built in logger' do
        hide_const('Rails')
        expect(Hubkit::Logger.inner_logger).to be_an_instance_of ::Logger
      end
    end
  end
end
