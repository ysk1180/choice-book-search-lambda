require 'rakuten_book_api_service'
require 'rakuten_book_display'

class RakutenSearch
  attr_reader :keyword, :page
  TECH_BOOK_GENRES_FULL = [
    '001003007', # 絵本・児童書・図鑑 → その他
    '001012010', # 科学・技術
    '001012010001', # 科学・技術 → 工学
    '001020009', # 新書 → パソコン・システム開発
  ]
  TECH_BOOK_GENRE_LV2 = '001005' # パソコン・システム開発

  def initialize(keyword, page)
    @keyword = keyword
    @page = page
  end

  def run
    books = response[:items].map { |item| RakutenBookDisplay.new(item).run }
    books = books.select{ |item| valid_genre?(item[:genre_id]) }
    {
      count: books.count,
      has_next_page: response[:page] < response[:page_count],
      books: books,
    }
  end

  private

  def response
    @response ||= RakutenBookApiService.new.search(
      title: keyword,
      hits: 20,
      page: page,
    )
  end

  def valid_genre?(id)
    return true if id.nil? || id == ''

    ids = id.split('/')
    ids.any?{ |id| TECH_BOOK_GENRES_FULL.include?(id) || id.slice(0..5) == TECH_BOOK_GENRE_LV2 }
  end
end
