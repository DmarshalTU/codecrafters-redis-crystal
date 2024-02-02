def message_parser(command_parts, server_state : State)
  command = command_parts.join("\r\n")
  puts "COMMAND PARTS: #{command_parts}"
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

  # Handling SET command
  puts "COMMAND: #{command}"
  if parts.size >= 7 && parts[0] == "*3" && parts[1] == "$3" && parts[2].upcase == "SET" && parts[3].starts_with?("$")
    puts "SET"
    key = parts[4]
    puts "KEYS: #{key}"
    value = parts[6]
    puts "VALUES: #{value}"
    server_state.store[key] = value
    return "+OK\r\n"
  elsif parts.size >= 5 && parts[2].upcase == "GET" && parts[0] == "*2" && parts[3].starts_with?("$")
    puts "GET"
    key = parts[4]
    puts "KEYG: #{key}"
    if server_state.store.has_key?(key)
      value = server_state.store[key]
      puts "PARTSG: #{parts[3][1..].to_i}"
      puts "VALUEG: #{value}"
      return "$#{parts.size}\r\n#{value}\r\n"
    else
      return "-Error: Key not found\r\n"
    end
  end

  puts "NOT SUPPORTED: #{command}"
  return nil # Return nil if the command does not match any supported command
end
