require 'spec_helper'

describe Log4rAuditor do
  before :all do
    @iut = Log4rAuditor::Log4rAuditor.new
    @invalid_log4r_configuration = { 'foo' => 'bar' }
    @valid_log4r_configuration = { 'file_name' => 'logfile',
                                   'standard_stream' => 'stdout' }
    @iut.configure(@valid_log4r_configuration)
  end

  it 'has a version number' do
    expect(Log4rAuditor::VERSION).not_to be nil
  end

  context "when extending from AuditorAPI" do
    it 'should adhere to auditor api by not preventing exceptions' do
      expect {
        @iut.configure(@invalid_log4r_configuration)
      }.to raise_error(ArgumentError, "Invalid configuration provided")
      expect {
        @iut.set_audit_level(:something)
      }.to raise_error(ArgumentError, "Invalid audit level specified")
    end

    it 'has a method audit' do
      expect(@iut.respond_to?('audit')).to eq(true)
    end

    it 'has a method configuration_is_valid?' do
      expect(@iut.respond_to?('configuration_is_valid?')).to eq(true)
    end
  end

  context "when configured by AuditorAPI" do
    it 'should accept a valid configuration' do
      expect(@iut.configuration_is_valid?(@valid_log4r_configuration)).to eq(true)
    end

    it 'should reject an invalid configuration' do
      expect(@iut.configuration_is_valid?(@invalid_log4r_configuration)).to eq(false)
    end

    it 'should reject a configuration with empty log file name' do
      expect(@iut.configuration_is_valid?(@valid_log4r_configuration.dup.merge('file_name' => ''))).to eq(false)
    end

    it 'should reject a configuration with standard stream not set to stderr or stdout' do
      expect(@iut.configuration_is_valid?(@valid_log4r_configuration.dup.merge('standard_stream' => 'stdout'))).to eq(true)
      expect(@iut.configuration_is_valid?(@valid_log4r_configuration.dup.merge('standard_stream' => 'stderr'))).to eq(true)
      expect(@iut.configuration_is_valid?(@valid_log4r_configuration.dup.merge('standard_stream' => 'none'  ))).to eq(true)
      expect(@iut.configuration_is_valid?(@valid_log4r_configuration.dup.merge('standard_stream' => 'stdbla'))).to eq(false)
    end
  end

  context "when asked by AuditorAPI to audit" do
    it "should submit audit to log file with data received" do
      test_id = "#{SecureRandom.hex(32)}" #Create an unique test identifier that will be used to correlate the log message
      @iut.audit("#{test_id} some audit event message")
      latest_message = get_latest_audit_entry_from_file(@valid_log4r_configuration['file_name'])
      expect(latest_message.include?(test_id)).to eq(true) #Check if the test identifier is in the retrieved message
    end

  end
end
