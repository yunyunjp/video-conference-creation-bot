require 'dotenv'
require 'net/http'
require "json/add/core"
require 'jwt'

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
  
  payload_for_jwt = {
    iss: ENV['API_KEY'],
    exp: Time.now.to_i + 36000
  }

  jwt = JWT.encode(payload_for_jwt, ENV['API_SECRET'],'HS256')

  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{jwt}"
  }

  req = Net::HTTP::Post.new(uri.path)
  req.body = payload
  
  req.initialize_http_header(headers)

  res = http.request(req)
  join_url = JSON.parse(res.body)['join_url']

  daily_person = fetch_daily_person(ENV['SPREAD_SHEET_URL'])

  notify_slack(join_url, daily_person)
end

def fetch_daily_person(uri)
  uri = URI.parse(uri)
  http = Net::HTTP.new(uri.hostname, uri.port)
  req = Net::HTTP::Get.new(uri.request_uri)
  http.use_ssl = true
  res = http.request(req)

  case res
  when Net::HTTPOK
    res.body.force_encoding("UTF-8")
  when Net::HTTPFound
    fetch_daily_person(res["location"])
  end
end

def notify_slack(join_url, daily_person)
  uri = URI.parse(ENV['WEBHOOK_URL'])

  slack_text = <<-EOS
    <!here> 会議が始まります。
    担当者：#{daily_person}

    Zoom会議には以下URLで入れます。
    #{join_url}
  EOS

   payload = {
    username: "デイリーお知らせbot",
    icon_emoji: ":spiral_calendar_pad",
    channel: "#会議担当者の通知",
    text: slack_text
  }.to_json

   Net::HTTP.post_form(uri, { payload: payload })
end

pp lambda_handler