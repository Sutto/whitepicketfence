require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-aggregates'
require 'dm-serializer'

class SMS
  include DataMapper::Resource
  
  property :id,         Serial
  property :contents,   String
  property :number,     String
  property :status,     String
  property :type,       String
  property :created_at, DateTime
  property :updated_at, DateTime

  validates_present :contents, :number, :status, :type

  def send_with_modem(modem)
    contents = self.contents.to_s[0, 160]
    if modem && modem.send_sms(number, contents)
      self.update_attributes :status => "sent"
      return true
    else
      return false
    end
  end

  def self.setup!
    DataMapper.setup(:default, "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/messages.sqlite3")
    self.auto_upgrade!
  end
  
  def self.receive(params = {})
    sms = SMS.new(params)
    sms.type   = "incoming"
    sms.status = "received"
    return sms
  end
  
  def self.queue(params = {})
    params[:number] = params.delete(:from) if params[:from]
    sms = SMS.new(params)
    sms.type   = "outgoing"
    sms.status = "pending"
    return sms
  end
  
  def self.send_pending(modem)
    unsent = []
    self.queued.each do |pending|
      unsent << pending unless pending.send_with_modem(modem)
    end
    return unsent
  end
  
  def self.queued
    self.all(:conditions => ['type = ? AND status = ?', "outgoing", "pending"])
  end
  
end

SMS.setup!

