class Zoom
  class << self
    def reservation_meeting
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

      jwt = JWT.encode(payload_for_jwt, ENV['API_SECRET'], 'HS256')

      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{jwt}"
      }

      req = Net::HTTP::Post.new(uri.path)
      req.body = payload

      req.initialize_http_header(headers)

      res = http.request(req)
      join_url = JSON.parse(res.body)['join_url']
    end
  end
end