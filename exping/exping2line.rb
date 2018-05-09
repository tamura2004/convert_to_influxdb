require "pathname"
require "csv"
require "time"

path1 = Pathname.new("H:/70-2016/2717010021-00-a_Windows10端末（PC・タブレット）導入/サービス端末不具合調査/SmartStore/20180501_虎ノ門支店")
path2 = Pathname.new("H:/70-2016/2717010021-00-a_Windows10端末（PC・タブレット）導入/サービス端末不具合調査/SmartStore/20180501-02_虎ノ門")

timestamp = Time.now.strftime("%H%M%S")
outname = sprintf("exping_%s.line", timestamp)
outf = open(outname,"wb") # バイナリモードにしないと改行コードがCR+LFになりinfluxdbインポートでエラー

outf.print "# DDL\n"
outf.print "CREATE DATABASE perf\n\n"
outf.print "# DML\n"
outf.print "# CONTEXT-DATABASE: perf\n\n"

$count = 0

[path1, path2].each do |path|
	path.find do |file|

		next unless file.file?
		next unless file.to_s =~ /虎ノ門/
		next unless file.to_s =~ /exping/i

		puts file
		STDOUT.flush

		CSV.foreach(file).with_index do |row, i|
			next if i == 0
			row.shift
			date, host, ip, result = *row
			timestamp = Time.parse(date).to_i * 1_000_000_000

			client = case file.to_s
				when /#1/ then "D3SD2001"
				when /#2/ then "D3SD2003"
				when /#3/ then "R7400541"
				when /#4/ then "5CG74647MX"
			end

			if result =~ /^Time:.*ms$/
				ms = result.scan(/\d+/).first
				outf.printf("ExpingResponse,client=%s,host=%s,location=tora response=%s %d\n",client,host,ms,timestamp)

			else
				result.gsub!(/\s+/,"_")
				outf.printf("ExpingError,client=%s,host=%s,location=tora,type=%s error=1 %d\n",client,host,result,timestamp)
			end

			# $count += 1
			# exit if $count > 200
		end
	end
end