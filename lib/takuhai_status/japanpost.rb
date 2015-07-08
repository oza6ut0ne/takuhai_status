require 'open-uri'
require 'nokogiri'

module TakuhaiStatus
	class JapanPost
		attr_reader :key, :time, :state

		def initialize(key)
			@key = key.gsub(/[^0-9]/, '')
			@time, @state = check
		end

		def finish?
			return @state == 'お届け先にお届け済み'
		end

	private
		def check
			uri = "https://trackings.post.japanpost.jp/services/srv/search/direct?reqCodeNo1=#{@key}"
			doc = Nokogiri(open(uri, &:read))

			begin
				cols = doc.css('.tableType01')[1].css('tr')
				col = cols[cols.size - 2]
				stime = col.css('td')[0].text
				time = Time.parse(stime)
				state = col.css('td')[1].text

				return time, state
			rescue NoMethodError
				raise NotMyKey
			rescue ArgumentError
				return Time.now, ''
			end
		end
	end
end
