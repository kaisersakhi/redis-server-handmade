# frozen_string_literal: true

require 'socket'
require_relative 'kommand_parser'

# Simple TCP server that accepts connections from clients and stores data
class KServer
  def initialize
    super
    @data_store = {}
    @clients = []
    @port_number = '4987'
    @parser = KommandParser.new
  end

  def start
    tcp_server = TCPServer.new port_number
    puts "Server started at: #{Time.now}"

    watch_for_clients(tcp_server)

    loop do
      next if clients.empty?
      # NOTE: server becomes readable when any client tries to connect to it.
      select_res = IO.select(clients + [tcp_server])
      select_res[0].each do |socket|
        if socket.is_a?(TCPServer)
          clients << tcp_server.accept
        elsif socket.is_a?(TCPSocket)
          # Get command from the client and parse
          client_command_args = socket.read_nonblock(1024, exception: false)
          handle_client(client_command_args, socket) do |response|
            socket.puts response
          end
        end
      end
    end
  end

  def handle_client(client_command, client)
    if client_command.nil?
      clients.delete(client)
      puts "Client #{client.peeraddr} has been dropped."
    elsif client_command == :wait_readable
      return
    elsif client_command.strip.empty?
      puts "Empty request received from #{client}"
    else
      if block_given?
        parser.parse(client_command) do |command, options, err|
          yield err unless err.empty?
          response = if command == :set
                       data_store[options[0]] = options[1]
                       'OK'
                     else
                       data_store[options[0]]
                     end
          yield response
        end
      end
    end
  end

  def watch_for_clients(server)
    Thread.new do
      loop do
        new_client = server.accept
        clients << new_client
        puts "New client connected: #{new_client.peeraddr}"
      end
    end
  end

  attr_accessor :data_store, :clients, :port_number, :parser
end

k_server = KServer.new
k_server.start
