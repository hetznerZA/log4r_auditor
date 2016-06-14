
def get_latest_audit_entry_from_file(messages_file)
  `tail -n 1 #{messages_file}`
end
