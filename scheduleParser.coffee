class Time
	constructor: (time) ->
		if typeof time is "string"
			throw "Invalid time #{time}" unless time.match /^\d{1,2}:\d{1,2}$/
			[@hours, @minutes] = (Number(t) for t in time.split ":")
			throw "Out of range time #{time}" unless 0 <= @hours < 24 and 0 <= @minutes < 60
		else if typeof time is "number" and time % 1 is 0
			throw "Out of range time #{time}" unless 0 <= time < 1440
			@hours = Math.floor(time / 60)
			@minutes = time % 60
		else
			throw "Unknown input type (#{typeof time}) for input #{time}"
	
	toString: () ->
		"#{@hours}:" + (if @minutes < 10 then "0#{@minutes}" else "#{@minutes}")
	valueOf: () ->
		@hours * 60 + @minutes

minuteByMinute = (timeRange) ->
	unless timeRange.match /^\d{1,2}:\d{2}-\d{1,2}:\d{2}$/
		throw Error("Bad input to minuteByMinute: #{timeRange}")
	
	[startTime, endTime] = (new Time(time) for time in timeRange.split "-")
	unless startTime < endTime
		throw Error("Start time after end time in minuteByMinute: #{timeRange}")
	
	output = []
	for time in [startTime + 0..endTime - 1]
		time = new Time time
		output.push time.toString()
	output

parseSchedule = (data) ->
	output = []
	classes = data.names
	for day in data.schedule
		today = {}
		for timeRange, classCode of day
			for time in minuteByMinute timeRange
				today[time] = classes[classCode]
		output.push today
	output
	
readData = (file) ->
	fs = require "fs"
 
	JSON.parse fs.readFileSync file, 'utf8'

getClassFromTime = (day, time, schedule) ->
	schedule[day][new Time(time)] or "None"

getCurrentClass = (schedule) ->
	now = new Date()
	getClassFromTime now.getDay(), "#{now.getHours()}:#{now.getMinutes()}", schedule
		
schedule = parseSchedule readData "#{__dirname}/blockschedule.json"

console.log getClassFromTime 2, "12:01", schedule
console.log getCurrentClass schedule