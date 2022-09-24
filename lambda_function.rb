require 'rakuten_search'

def lambda_handler(event:, context:)
  keyword = event['q']
  return [].to_json if keyword.nil? || keyword == ''

  page = (event['page'] || 1).to_i

  RakutenSearch.new(keyword, page).run
end