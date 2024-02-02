require "socket"
require "./message_parser"

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
end

Server.new.start
