require "socket"

# Ensure that the program terminates on SIGTERM, https://github.com/crystal-lang/crystal/issues/8687
Signal::TERM.trap { exit }

class YourRedisServer
  def start
    puts("Logs from your program will appear here!")

    server = TCPServer.new("0.0.0.0", 6379, reuse_port: true)
    loop do
      client = server.accept?
      client && spawn handle_client(client)
    end
  end

  def handle_client(client)
    while mmessage = client.gets
      if mmessage == "ping"
        client.puts "+PONG\r\n"
      end
    end
  end
end

YourRedisServer.new.start
