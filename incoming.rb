require File.join(File.dirname(__FILE__), "server_tools")

$timeout = (ENV["LOOP_DELAY"] || 5).to_i

# loop do
#   puts "Sending pending messages..."
#   SMS.send_pending($modem)
#   sleep $timeout
# end

class WPFReceiver
  def initialize(modem)
    modem.receive(method(:incoming))
    @modem = modem
  end

  def incoming(from, datetime, message)
    SMS.receive(:contents => message, :number => from)
    # TODO: Dispatch hooks here.
  end
end

WPFReceiver.new($modem)