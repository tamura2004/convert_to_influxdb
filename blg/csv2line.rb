require "csv"
require "pp"

raise "ファイル名を指定してください" if ARGV.size.zero?

Header = Struct.new(:category, :hostname, :instance, :index, :label)

ARGV.each do |inname|
	raise "#{inname}はCSVファイルではありません" unless File.extname(inname) == ".csv"	

	basename = File.basename(inname,".csv")
	timestamp = Time.now.strftime("%H%M%S")
	outname = sprintf("%s_%s.line", basename, timestamp)
	outf = open(outname,"wb") # バイナリモードにしないと改行コードがCR+LFになりinfluxdbインポートでエラー

	outf.print "# DDL\n"
	outf.print "CREATE DATABASE perf\n\n"
	outf.print "# DML\n"
	outf.print "# CONTEXT-DATABASE: perf\n\n"

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
			sec = Time.local(year,month,day,hour,minute,second).to_i
			msec = ms.to_i
			timestamp = sec * 1_000_000_000 + msec * 1_000_000

			row.each_with_index do |col, i|
				next if col == " " # データなし
				next if col == "0" # relogバグ対応
				header = headers[i].to_a.compact

				if header.size == 3
					outf.printf("%s,host=%s %s=%s %d\n", *header, col, timestamp)
				else
					outf.printf("%s,host=%s,instance=%s,index=%s %s=%s %d\n", *header, col, timestamp)
				end
			end
		end
	end
end

