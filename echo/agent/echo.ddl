#
# echo.ddl
#

metadata :name        => 'echo',
         :description => 'Agent that echoes everything back to the sender',
         :author      => 'Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>',
         :license     => 'Apache License, Version 2.0',
         :version     => '1.0',
         :url         => 'http://github.com/kwilczynski',
         :timeout     => 5

action 'echo', :description => 'Echoes message back to the sender' do
  display :always

  input :message,
    :prompt      => 'Message',
    :description => 'Message that will be sent back to the sender',
    :type        => :string,
    :validation  => '^.+$',
    :optional    => false,
    :maxlength   => 256

  output :message,
    :description => 'Message that was sent by the sender',
    :display_as  => 'Message'

  output :size,
    :description => 'Size of the message that was sent by the sender',
    :display_as  => 'Size'

  output :hash,
    :description => 'Either MD5 or SHA1 checksum of the message that was sent',
    :display_as  => 'Hash'
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
