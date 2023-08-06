require 'socket'

class KClient
  def initialize
    @port = 4987
    @host = "localhost"
    @socket = TCPSocket.new host, port
  end

  def get(key)
    socket.puts "GET #{key}"
    socket.gets
  end

  def set(key, value)
    socket.puts "SET #{key} #{value}"
    socket.gets
  end

  def quit
    socket.close
  end

  attr_accessor :port, :host, :socket
end