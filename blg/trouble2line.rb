require "csv"
require "pp"

raise "ファイル名を指定してください" if ARGV.size.zero?

Header = Struct.new(:category, :hostname, :instance, :label)
priority = {
	pdf: 6,
	keyboard: 5,
	camera: 4,
	edge: 3,
	ui: 2,
	group_policy: 1
}

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
		next if i == 0

		id,date,time,hostname,category = row

		year, month, day = date.split(/\//)
		hour, minute, second = time.split(/:/)

		sec = Time.local(year,month,day,hour,minute,second).to_i
		timestamp = sec * 1_000_000_000

		value = priority[category.to_sym]

		outf.printf("Trouble,host=%s,category=%s,id=%s priority=%d %d\n", hostname, category, id, value, timestamp)

	end
end

