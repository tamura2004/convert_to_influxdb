
ranges = [
	[[2018,4,26,9,0,0],[2018,5,2,19,0,0]],
	[[2018,4,26,9,0,0],[2018,4,26,19,0,0]],
	[[2018,4,27,9,0,0],[2018,4,27,19,0,0]],
	[[2018,5,1,9,0,0],[2018,5,1,19,0,0]],
	[[2018,5,2,9,0,0],[2018,5,2,19,0,0]],
	[[2018,5,2,9,30,0],[2018,5,2,9,40,0]],
	[[2018,5,2,10,30,0],[2018,5,2,10,40,0]],
	[[2018,5,2,10,50,0],[2018,5,2,11,0,0]],
	[[2018,5,2,11,10,0],[2018,5,2,11,20,0]],
	[[2018,5,2,11,38,0],[2018,5,2,11,48,0]],
	[[2018,5,2,14,45,0],[2018,5,2,14,55,0]],
	[[2018,5,2,14,55,0],[2018,5,2,15,5,0]],
	[[2018,5,2,15,3,0],[2018,5,2,15,13,0]],
	[[2018,5,2,16,0,0],[2018,5,2,16,10,0]],
]

def time2unixnano(year,month,day,hour,minute,second)
	Time.local(year,month,day,hour,minute,second).to_i * 1_000
end

ranges.each do |st, en|
	stime = time2unixnano(*st)
	etime = time2unixnano(*en)

	p st
	p en

	puts "http://localhost:8080/d/wOeVNYGiz/li-zhou-hu-nomen-pahuomansugurahu?orgId=1&from=#{stime}&to=#{etime}"
end