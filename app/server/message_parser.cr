def message_parser(command_parts)
  command = command_parts.join("\r\n")
  puts "COMMAND: #{command}"
  parts = command.split("\r\n")

  # Check for the PING command
  if parts.size >= 3 && parts[0] == "*1" && parts[1] == "$4" && parts[2].upcase == "PING"
    return "+PONG"
  end

  # Check if it's an ECHO command
  if parts.size >= 5 && parts[0] == "*2" && parts[1] == "$4" && parts[2].upcase == "ECHO" && parts[3].starts_with?("$")
    message_length = parts[3][1..].to_i
    message_to_echo = parts[4]

    if message_to_echo.bytesize == message_length
      response = "$#{message_length}\r\n#{message_to_echo}\r\n"
      return response
    else
      puts "Invalid ECHO command length"
      return nil
    end
  end

  puts "NOT SUPPORTED: #{command}"
  return nil # Return nil if the command does not match any supported command
end
