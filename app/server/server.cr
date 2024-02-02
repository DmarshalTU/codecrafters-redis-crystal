require "socket"
# require "./message_parser"

# Ensure that the program terminates on SIGTERM, https://github.com/crystal-lang/crystal/issues/8687
Signal::TERM.trap { exit }

class Server
  def start
    puts("LOGS: Server started")

    server = TCPServer.new("0.0.0.0", 6379, reuse_port: true)
    loop do
      client = server.accept?
      client && spawn do
        handle_client(client)
      end
    end
  end

  def handle_client(client)
    puts "Client connected! #{client.inspect}"
    command_buffer = [] of String
    expected_lines = 0

    loop do
      begin
        line = client.gets
        break unless line
        command_buffer << line.strip

        if command_buffer.size == 1 && command_buffer.first.starts_with?("*")
          # Determine the number of lines expected for a multi-line command
          expected_lines = command_buffer.first[1..].to_i * 2 + 1
        elsif expected_lines == 0
          # Single-line command
          expected_lines = 1
        end

        if command_buffer.size == expected_lines
          # We have a complete command
          response = message_parser(command_buffer)
          puts "Sending response: #{response}" if response
          client << response + "\r\n" unless response.nil?
          command_buffer.clear
          expected_lines = 0
        end
      rescue ex : IO::EOFError
        puts "Client disconnected!"
        client.close
        break
      end
    end
  end

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

end

Server.new.start
