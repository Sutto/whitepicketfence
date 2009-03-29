require File.join(File.dirname(__FILE__), "server_tools")
gem 'taf2-curb'
require 'curl'

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
    sms = SMS.receive(:contents => message, :number => from)
    json = {
      "number"   => from,
      "contents" => message,
      "id"       => sms.id,
      "path"     => "/messages/#{sms.id}"
    }.to_json
    dispatch_json(json)
  end
  
  protected
  
  def dispatch_json(payload)
    data = Curl::PostField.content('payload', payload)
    settings['hook_urls'].each do |url|
      Curl::Easy.http_post(url, data) rescue nil
    end
  end
  
end

WPFReceiver.new($modem)