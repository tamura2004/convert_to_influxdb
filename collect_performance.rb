require "csv"
require "pp"
require "time"

outfile = CSV.open("tora600/out/perf_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv","w")
outfile << %w(year month day hour minute second ms hostname category instance label value)

points = [
	[26,16],
	[26,17],
	[27,13],
	[27,14],
]

Dir.glob("tora600/*.csv").each do |infile|

	categories = []
	instances = []
	labels = []
	hostname = ""

	CSV.foreach(infile) do |row|
		preminute = ""
		if row[0] =~ /PDH/
			row.each do |col|
				foo, hostname, category, label = col.split(/[\\]+/)
				label ||= ""
				category ||= ""

				category, instance = category.split(/[\(\)]/)
				category ||= ""
				instance ||= ""

				category.gsub!(/%/,"Percent_")
				instance.gsub!(/%/,"Percent_")
				label.gsub!(/%/,"Percent_")

				category.gsub!(/[^a-zA-Z0-9]+/,"_")
				instance.gsub!(/[^a-zA-Z0-9]+/,"_")
				label.gsub!(/[^a-zA-Z0-9]+/,"_")

				categories << category
				instances << instance
				labels << label
			end
		else
			next if row[0].nil?

			month,day,year,hour,minute,second,ms = row[0].split(/[\s\:\.\/]/)
			minute = sprintf("%02d",(minute.to_i/10)*10)
			# next unless points.any?{|dd,hh| dd == day.to_i && hh == hour.to_i}

			row.each_with_index do |col, i|
				next if i.zero?
				next if col == " "
				#next if instances[i] == "_Total"

				category = categories[i]
				instance = instances[i]
				# 	when /microsoft/i then "MicrosoftEdge"
				# 	when /dwm/ then "DesktopWindowManeger"
				# 	when /svchost/ then "ServiceHost"
				# 	else "Other"
				# end
				label = labels[i]
				next unless category == "Process"
				next unless label == "Percent_Processor_Time"


				outfile << [year,month,day,hour,minute,second,ms,hostname,category,instance,label,col]
			end
		end
	end
end

outfile.close
