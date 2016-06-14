require 'log4r_auditor/auditor'
require 'soar_auditing_format'
require 'time'
require 'securerandom'

class Main
  def test_sanity
    @iut = Log4rAuditor::Log4rAuditor.new
    @log4r_configuration = { 'file_name' => 'logfile',
                             'standard_stream' => 'stdout' }
    @iut.configure(@log4r_configuration)
    @iut.set_audit_level(:debug)

    my_optional_operation_field = SoarAuditingFormatter::Formatter.optional_field_format("operation", "Http.Get")
    my_optional_method_name_field = SoarAuditingFormatter::Formatter.optional_field_format("method", "#{self.class}::#{__method__}::#{__LINE__}")
    @iut.debug(SoarAuditingFormatter::Formatter.format(:debug,'my-sanity-service-id',SecureRandom.hex(32),Time.now.iso8601(3),"#{my_optional_method_name_field}#{my_optional_operation_field} test message with optional fields"))
  end
end

main = Main.new
main.test_sanity
