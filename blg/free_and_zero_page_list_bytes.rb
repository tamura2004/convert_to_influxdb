require "csv"
require "pp"

hosts = []
outf = open("free_and_zero_page_list_bytes.txt","w")


outf.puts <<EOF
# DDL
CREATE DATABASE perf

# DML
# CONTEXT-DATABASE: perf
EOF

CSV.foreach("free_and_zero_page_list_bytes.csv").with_index do |row, i|
	if i == 0
		row.shift
		hosts = row.map{|e|e.split(/\\+/)[1]}

	else
		datetime = row.shift
		month,day,year,hour,minute,second,ms = datetime.split(/[\s\:\.\/]/)
		timestamp = Time.local(year,month,day,hour,minute,second).to_i*1000000000

		row.each_with_index do |col, i|
			next if col == " "
			outf.puts "memory,host=#{hosts[i]} value=#{col} #{timestamp}"
		end
	end
end
