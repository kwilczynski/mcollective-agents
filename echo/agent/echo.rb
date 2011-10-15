#
# echo.rb
#

module MCollective
  module Agent
    class Echo < RPC::Agent
      metadata :name        => 'echo',
               :description => 'Agent that echoes everything back to the sender',
               :author      => 'Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>',
               :license     => 'Apache License, Version 2.0',
               :version     => '1.0',
               :url         => 'http://github.com/kwilczynski',
               :timeout     => 5

      action 'echo' do
        validate :message, String

        message = request[:message]
        hash    = request[:hash]

        if hash and not hash.empty?
          case hash.to_s
          when /^md5$/
            require 'digest/md5'
            hash = Digest::MD5.hexdigest(hash)
          when /^sha1$/
            require 'digest/sha1'
            hash = Digest::SHA1.hexdigest(hash)
          end

          reply[:hash] = hash
        end

        reply[:message] = message
        reply[:size]    = message.size
      end
    end
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
