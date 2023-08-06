# frozen_string_literal: true

class KommandParser
  def parse(command_args)
    response = []
    begin
      command = command_args.downcase.strip.split(' ')[0]
      args = command_args.strip.split(' ')[1..-1]

      if command == 'set'
        if args.length != 2
          raise ArgumentError, "(error) ERR wrong number of arguments for '#{command.upcase}' command"
        end
        response = [:set, [args[0], args[1]], '']
      elsif command == 'get'
        if args.length != 1
          raise ArgumentError, "(error) ERR wrong number of arguments for '#{command.upcase}' command"
        end
        response = [:get, [args[0]], '']
      end
    rescue ArgumentError => e
      response = [:none, [], e.message]
    end

    if block_given?
      yield response
    else
      'This method need a block.'
    end
  end
end
