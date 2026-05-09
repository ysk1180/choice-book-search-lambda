require 'net/http'
require 'uri'
require 'json'

class RakutenBookApiService
  ENDPOINT = 'https://openapi.rakuten.co.jp/engine/api/BooksBook/Search/20170404'.freeze
  ORIGIN = 'https://teckbook.net'.freeze

  class Error < StandardError; end
  class ConfigurationError < Error; end
  class RequestError < Error; end

  def initialize(application_id: ENV['RWS_APPLICATION_ID'], access_key: ENV['RWS_ACCESS_KEY'], affiliate_id: ENV['RWS_AFFILIATE_ID'])
    @application_id = application_id
    @access_key = access_key
    @affiliate_id = affiliate_id
  end

  def search(title:, page: 1, hits: 20)
    raise ConfigurationError, 'RWS_APPLICATION_ID is not set' if @application_id.nil? || @application_id.empty?
    raise ConfigurationError, 'RWS_ACCESS_KEY is not set' if @access_key.nil? || @access_key.empty?

    params = {
      'applicationId' => @application_id,
      'format' => 'json',
      'formatVersion' => '2',
      'title' => title,
      'hits' => hits,
      'page' => page,
    }
    params['affiliateId'] = @affiliate_id if @affiliate_id && !@affiliate_id.empty?

    body = get_json(params)

    {
      items: body['Items'] || [],
      page: body['page'] || page,
      page_count: body['pageCount'] || 0,
      count: body['count'] || 0,
    }
  end

  private

  def get_json(params)
    uri = URI(ENDPOINT)
    uri.query = URI.encode_www_form(params)

    request = Net::HTTP::Get.new(uri)
    request['accessKey'] = @access_key
    request['Origin'] = ORIGIN
    request['Referer'] = "#{ORIGIN}/"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    unless response.is_a?(Net::HTTPSuccess)
      raise RequestError, "Rakuten API request failed: #{response.code} #{response.body}"
    end

    JSON.parse(response.body)
  end
end
