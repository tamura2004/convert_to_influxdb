require "csv"
require "pp"

raise "ファイル名を指定してください" if ARGV.size.zero?

Header = Struct.new(:category, :hostname, :instance, :index, :label)

ARGV.each do |inname|
	raise "#{inname}はCSVファイルではありません" unless File.extname(inname) == ".csv"	

	basename = File.basename(inname,".csv")
	timestamp = Time.now.strftime("%H%M%S")
	outname = sprintf("pivot_%s_%s.csv", basename, timestamp)
	outf = CSV.open(outname,"w")
	outf << %w(year month day hour minute second ms category hostname instance index label value)

	headers = []

	CSV.foreach(inname).with_index do |row, i|
		if i == 0
			row.shift
			row.each do |col|
				col.gsub!(/\s+/,"_")

				hostname, category, label = col.scan(/[^\\]+/)
				category, instance = category.scan(/[^\(\)]+/)
				instance, index = instance&.scan(/[^\#]+/)
				index ||= "0" unless instance.nil?

				headers << Header.new(category, hostname, instance, index, label)
			end
		else
			datetime = row.shift
			month,day,year,hour,minute,second,ms = datetime.split(/[\s\:\.\/]/)

			row.each_with_index do |col, i|
				next if col == " " # データなし
				next if col == "0" # データなし, relogバグ対応
				next unless headers[i].category == "Process"
				next unless headers[i].label =~ /Fault/
				next if headers[i].instance == "_Total"
				next unless second == "26" || second == "27"

				header = headers[i].to_a
				outf << [year, month, day, hour, minute, second, ms, *header, col]
			end
		end
	end
end

