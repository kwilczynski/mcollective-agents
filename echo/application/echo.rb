#
# echo.rb
#

module MCollective
  class Application::Echo < Application
    description 'Sends message that echoes back to sender'

    usage 'mco echo [OPTIONS] [FILTERS] <MESSAGE>'

    option :md5,
      :description => 'Ask for MD5 checksum of the message',
      :arguments   => ['-m', '--md5', '--md5sum'],
      :type        => :bool,
      :required    => false

    option :sha1,
      :description => 'Ask for SHA1 checksum of the message',
      :arguments   => ['-s', '--sha1', '--sha1sum'],
      :type        => :bool,
      :required    => false

    option :formatted,
      :description => 'Show well-formatted output',
      :arguments   => ['-f', '--formatted'],
      :type        => :bool,
      :required    => false

    option :details,
      :description => 'Show more comprehensive summary',
      :arguments   => ['-d', '--details'],
      :type        => :bool,
      :required    => false

    def print_statistics(statistics)
      print "\n---- echo summary ----\n"
      puts "           Nodes: #{statistics[:responses] +
        statistics[:noresponsefrom].size} / #{statistics[:responses]}"
      printf("    Elapsed Time: %.2f s\n\n", statistics[:blocktime])
    end

    def post_option_parser(configuration)
      if ARGV.size < 1
        raise 'Please specify message to sent and optional arguments'
      else
        configuration[:message] = ARGV.shift

        md5  = configuration[:md5]
        sha1 = configuration[:sha1]

        formatted = configuration[:formatted]
        verbose   = options[:verbose]

        if md5 and sha1
          raise 'Please select either MD5 or SHA1 checksum'
        else
          configuration[:hash] = :md5  if md5
          configuration[:hash] = :sha1 if sha1
        end

        if formatted and verbose
          # Suppress extra information ...
          options[:verbose] = false
          raise 'Please select either formatted or verbose output'
        end
      end
    end

    def main
      first = true

      message   = configuration[:message]
      hash      = configuration[:hash]
      formatted = configuration[:formatted]
      details   = configuration[:details]

      if hash
        arguments = { :message => message, :hash => hash }
      else
        arguments = { :message => message }
      end

      rpc_echo = rpcclient('echo', { :options => options })

      rpc_echo.send('echo', arguments).each do |node|
        # We want new line here ...
        puts if first and not rpc_echo.progress

        sender = node[:sender]
        data   = node[:data]

        #
        # If the status code is non-zero and data is empty then we
        # assume that something out of an ordinary had place and
        # therefore assume that there was some sort of error ...
        #
        unless node[:statuscode].zero? and data
          message, hash, size = 'error', 'error', 0
        else
          message = data[:message]
          hash    = data[:hash]
          size    = data[:size]
        end

        if rpc_echo.verbose
          if hash
            printf("%-40s size=%d, hash=%s, message=%s\n",
              sender, size, hash, message)
          else
            printf("%-40s size=%d, message=%s\n",
              sender, size, message)
          end

          puts "\t\t#{node[:statusmsg]}"
        else
          if formatted
            printrpc(node)
          else
            printf("%-40s message=%s\n", sender, message)
          end
        end

        first = false
      end

      rpc_echo.disconnect

      if details
        # Force more detailed output ...
        options[:verbose] = true
        printrpcstats({ :caption => 'echo summary' })
      else
        print_statistics(rpc_echo.stats)
      end
    end
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
