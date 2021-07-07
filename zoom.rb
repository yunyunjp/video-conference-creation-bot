class Zoom
  class << self
    def reservation_meeting
      path = "https://api.zoom.us/v2/users/#{ENV['USER_ID']}/meetings"
      uri = URI.parse(path)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      req = Net::HTTP::Post.new(uri.path)
      req.body = Zoom.payload

      req.initialize_http_header(Zoom.headers)

      res = http.request(req)
      join_url = JSON.parse(res.body)['join_url']
    end
  end  

  private
  class << self
    def payload
      {
        topic: "デイリー",
        type: '1',
        duration: '40',
        timezone: "Asia/Tokyo",
        password: "",
        agenda: "進捗報告",
      }.to_json
    end
 
    def headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{Zoom.generate_jwt}"
      }
    end
 
    def generate_jwt
      payload_for_jwt = {
        iss: ENV['API_KEY'],
        exp: Time.now.to_i + 36000
      }
 
      JWT.encode(payload, ENV['API_SECRET'], 'HS256')
    end
  end
end