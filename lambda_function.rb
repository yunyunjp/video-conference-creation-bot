require 'dotenv'
require 'net/http'
require "json/add/core"

Dotenv.load

def lambda_handler
  path = "https://api.zoom.us/v2/users/#{ENV['USER_ID']}/meetings"
  uri = URI.parse(path)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  payload = {
    topic: "デイリー",
    type: "1",
    duration: "40",
    timezone: "Asia/Tokyo",
    password: "",
    agenda: "進捗報告"
  }.to_json
  
  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{ENV['JWT']}"

  req = Net::HTTP::Post.new(uri.path)
  req.body = payload
  
  req.initialize_http_header(headers)

  res = http.request(req)
  join_url = JSON.parse(res.body)['join_url']
end

pp lambda_handler