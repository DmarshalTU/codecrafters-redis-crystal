def message_parser(command)
  puts "COMMAND: #{command}"

  # Split the command by line breaks
  parts = command.split("\r\n")

  # Check for the PING command
  if parts.any? { |part| part.upcase == "PING" }
    return "+PONG"
  end

  # ECHO command handling remains unchanged

  puts "NOT SUPPORTED: #{command}"
  return nil # Return nil if the command does not match any supported command
end