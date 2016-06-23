require 'bundler/setup'
require 'sinatra/base'
require 'json'
require 'rest-client'

class App < Sinatra::Base
  post '/callback' do
    params = JSON.parse(request.body.read)
    
    image_url = 'https://kigyotv.jp/wp/wp-content/uploads/2014/11/20141110044949-e1415606396142.jpg'

    params['result'].each do |msg|
      request_content = {
        to: [msg['content']['from']],
        toChannel: 1383378250, # Fixed  value
        eventType: "138311608800106203", # Fixed value
        content: [
          {
            "contentType": 1,
            "text": "First message"
          },
          {
            "contentType": 2,
            "originalContentUrl": image_url,
            "previewImageUrl": image_url
          }
        ]
      }

      endpoint_uri = 'https://trialbot-api.line.me/v1/events'
      content_json = request_content.to_json

      RestClient.proxy = ENV["LINE_OUTBOUND_PROXY"]
      RestClient.post(endpoint_uri, content_json, {
        'Content-Type' => 'application/json; charset=UTF-8',
        'X-Line-ChannelID' => ENV["LINE_CHANNEL_ID"],
        'X-Line-ChannelSecret' => ENV["LINE_CHANNEL_SECRET"],
        'X-Line-Trusted-User-With-ACL' => ENV["LINE_CHANNEL_MID"],
      })
    end

    "OK"
  end
end

run App
