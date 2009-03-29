require 'rubygems'
require 'sinatra'
require 'json'
require File.join(File.dirname(__FILE__), 'sms_model')

$settings = YAML.load_file(File.join(File.dirname(__FILE__), "wpf.yml"))

# Create a new message
post '/messages' do
  message = SMS.queue(params[:message].is_a?(Hash) ? params[:message] : {})
  if message.save
    response['Location'] = "/messages/#{message.id}"
    status 201
    message.to_json
  else
    status 422
    message.errors.to_hash.to_json
  end
end

# Status of an existing message
get '/messages/:id' do
  message = SMS.get(params[:id])
  if message.blank?
    status 404
    "Not found"
  else
    message.to_json
  end
end

get '/settings' do
  $settings.to_json
end