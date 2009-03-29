require File.join(File.dirname(__FILE__), "server_tools")

$timeout = (ENV["LOOP_DELAY"] || 5).to_i

loop do
  puts "Sending pending messages..."
  SMS.send_pending($modem)
  sleep $timeout
end