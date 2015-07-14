require 'crawler_rocks'
require 'json'
require 'iconv'
require 'pry'

class NcyuCourseCrawler

  def initialize
    @query_url = "https://web085003.adm.ncyu.edu.tw/pub_depta1.aspx"
    @ic = Iconv.new('utf-8//translit//IGNORE', 'big-5')
    @result_url = "https://web085003.adm.ncyu.edu.tw/pub_depta2.aspx"
  end

  def courses
    @courses = []

    # start write your crawler here:
    r = RestClient.get @query_url
    doc = Nokogiri::HTML(@ic.iconv(r))

    # doc.css('select[name="WebDep67"] option')
    # doc.css('select[name="WebDep67"] option')[0][:value]
    # doc.css('select[name="WebDep67"] option')[0].text

    # doc.css('select[name="WebDep67"] option').map{|opt| opt[:value]}

    # h = {"abc"=>123, 0=>"asdf", :symbol=>"asdf"}
    # h.each { |k, v| puts "key is #{k}, value is #{v}" }

    # (0..4).each {|i| puts i}
    # [1, 2, 3, 4, 5].each do |i|
    #   puts i
    # end

    # {"a" => 1}
    # {:a => 1}
    # {a: 1}

    post_dept_values = doc.css('select[name="WebDep67"] option').map{|opt| opt[:value] }

    post_dept_values.each do |dept_value|
      r = RestClient.post(@result_url, {
        "WebPid1" => nil,
        "Language" => "zh-TW",
        "WebYear1" => 104,
        "WebTerm1" => 1,
        "WebDep67" => dept_value,
      })
      doc = Nokogiri::HTML(@ic.iconv(r))

      binding.pry if dept_value == "236"

      table = doc.css('table[border="1"][align="center"][cellpadding="1"][cellspacing="0"][width="99%"]')[0]

      rows = table.css('tr:not(:first-child)')
      rows.each do |row|
        table_datas = row.css('td')

        course = {
          department_code: table_datas[2].text,
          # name: aaa,
          # code: aaa,
        }

        @courses << course
      end
      # File.write("temp/#{dept_value}.html", r)
    end

    # binding.pry
    # puts "hello"

    @courses
  end
end

crawler = NcyuCourseCrawler.new
File.write('ncyu_courses.json', JSON.pretty_generate(crawler.courses()))
