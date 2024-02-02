require "socket"

# Ensure that the program terminates on SIGTERM, https://github.com/crystal-lang/crystal/issues/8687
Signal::TERM.trap { exit }

class YourRedisServer
  def start
    puts("Logs from your program will appear here!")

    server = TCPServer.new("0.0.0.0", 6379, reuse_port: true)
    loop do
      client = server.accept?
      client && spawn do
        handle_client(client)
      end
    end
  end

  def handle_client(client)
    loop do
      begin
        message = client.read_line
      rescue ex : IO::EOFError
        client.close
        break
      end

      if message =~ /ping/
        client << "+PONG\r\n"
      end
    end
  end
end

YourRedisServer.new.start
