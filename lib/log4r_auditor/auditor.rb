require 'soar_auditor_api'
require 'log4r'

module Log4rAuditor
  class Log4rAuditor < SoarAuditorApi::AuditorAPI
    #Override of AuditorAPI configure method in order to perform post configuration setup
    def configure(configuration)
      super(configuration)
      post_configuration_setup
    end

    #inversion of control method required by the AuditorAPI to validate the configuration
    def configuration_is_valid?(configuration)
      required_parameters = ['file_name', 'standard_stream']
      required_parameters.each { |parameter| return false unless configuration.include?(parameter) }
      return false if configuration['file_name'].empty?
      return false unless ['stdout', 'stderr', 'none'].include?(configuration['standard_stream'])
      return true
    end

    #inversion of control method required by the AuditorAPI to hint direct call preference to auditor
    def prefer_direct_call?
      true
    end

    #inversion of control method required by the AuditorAPI to send the audit event to the auditor
    def audit(audit_data)
      @log4r.debug(audit_data)
    end

    private

    def post_configuration_setup
      @log4r = Log4r::Logger.new('soar_sc')
      @log4r.outputters = create_outputers
      @log4r
    end

    def create_outputers
      outputers = []
      outputers << create_log4r_file_output if create_log4r_file_output
      outputers << create_log4r_standard_stream_output if create_log4r_standard_stream_output
      outputers
    end

    def create_log4r_file_output
      logfile = Log4r::FileOutputter.new('fileOutputter', :filename => @configuration['file_name'],:trunc => false)
      logfile.formatter = create_log4r_pattern
      logfile
    end

    def create_log4r_standard_stream_output
      logstdout = Log4r::Outputter.stdout if 'stdout' == @configuration['standard_stream']
      logstdout = Log4r::Outputter.stderr if 'stderr' == @configuration['standard_stream']
      logstdout.formatter = create_log4r_pattern if logstdout
      logstdout
    end

    def create_log4r_pattern
      Log4r::PatternFormatter.new(:pattern => '%m')
    end
  end
end
