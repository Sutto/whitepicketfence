require 'rubygems'
require 'rubygsm'
require 'yaml'
require File.join(File.dirname(__FILE__), 'sms_model')

SETTINGS_PATH = File.join(File.dirname(__FILE__), "wpf.yml")
$settings     = YAML.load_file(SETTINGS_PATH)
$last_time    = File.mtime(SETTINGS_PATH)

def settings
  if $last_time < File.mtime(SETTINGS_PATH)
    $settings     = YAML.load_file(SETTINGS_PATH)
    $last_time    = File.mtime(SETTINGS_PATH)
  end
  return $settings
end

class FakeModem
  
  attr_accessor :port
  
  def initialize(port)
    self.port = port
  end
  
  def send_sms(to, contents)
    puts "Sending message via #{self.port}: #{to} => #{contents}"
    return true
  end
  
  def receive(blk)
    puts "Calling receive w/ #{blk.inspect}"
    puts "Enter messages in format: 'from_number, message', exit w/ exit"
    while (line = gets.strip).downcase != "exit"
      from, msg = line.split(", ", 2)
      blk.call(from, Time.now, msg)
    end
    puts "Exiting..."
  end
  
end

$modem = (ENV['WPF_TEST'] ? FakeModem : Gsm::Modem).new(settings["device_path"])