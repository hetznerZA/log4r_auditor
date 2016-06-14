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
      return false unless ['stdout', 'stderr'].include?(configuration['standard_stream'])
      return true
    end

    #inversion of control method required by the AuditorAPI to send the audit event to the auditor
    def audit(audit_data)
      @log4r.debug(audit_data)
    end

    private

    def post_configuration_setup
      @log4r = Log4r::Logger.new('soar_sc')
      @log4r.outputters = create_log4r_file_output, create_log4r_standard_stream_output
      @log4r
    end

    def create_log4r_file_output
      logfile = Log4r::FileOutputter.new('fileOutputter', :filename => @configuration['file_name'],:trunc => false)
      logfile.formatter = create_log4r_pattern
      logfile
    end

    def create_log4r_standard_stream_output
      logstdout = Log4r::Outputter.stdout if 'stdout' == @configuration['standard_stream']
      logstdout = Log4r::Outputter.stderr if 'stderr' == @configuration['standard_stream']
      logstdout.formatter = create_log4r_pattern
      logstdout
    end

    def create_log4r_pattern
      Log4r::PatternFormatter.new(:pattern => '%m')
    end
  end
end
