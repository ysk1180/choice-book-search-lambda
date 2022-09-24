require 'rakuten_web_service'
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
    books = request.map { |item| RakutenBookDisplay.new(item).run }
    books = books.select{ |item| valid_genre?(item[:genre_id]) }
    count = books.count
    has_next_page = request.next_page?
    {
      count: count,
      has_next_page: has_next_page,
      books: books
    }
  end

  private

  def request
    return @request if defined? @request

    RakutenWebService.configure do |c|
      c.application_id = ENV['RAKUTEN_APPID']
      c.affiliate_id = ENV['RAKUTEN_AFID']
    end

    @request ||= RakutenWebService::Books::Book.search(
      title: keyword,
      hits: 20,
      page: page,
      # books_genre_id: '001012010001', # GenreLevel:4の電気工学/別ジャンルにも技術書が含まれており、複数指定はできなかった..
    )
  end

  def valid_genre?(id)
    return true if id.nil? || id == ''

    ids = id.split('/')
    ids.any?{ |id| TECH_BOOK_GENRES_FULL.include?(id) || id.slice(0..5) == TECH_BOOK_GENRE_LV2 }
  end
end
