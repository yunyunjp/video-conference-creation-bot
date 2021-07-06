class SpreadSheet
  class << self
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
  end
end