require "socket"

# Ensure that the program terminates on SIGTERM, https://github.com/crystal-lang/crystal/issues/8687
Signal::TERM.trap { exit }

class YourRedisServer
  def start
    # You can use print statements as follows for debugging, they'll be visible when running tests.
    puts("Logs from your program will appear here!")

    server = TCPServer.new("0.0.0.0", 6379, reuse_port: true)
    return if (client = server.accept?).nil?
    client << "+PONG\r\n"
  end
end

YourRedisServer.new.start
