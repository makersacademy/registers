require 'airtable'
require 'active_support/all'
require 'awesome_print'
require 'date'
require 'business_time'

class Cohort

  def initialize(name, startDate, endDate)
    @name = name
    @startDate = startDate
    @endDate = endDate
  end

  def name
    @name
  end

  def startDate
    @startDate
  end

  def endDate
    @endDate
  end

end

cohorts = [
  Cohort.new("Government October 2018",
              Date.new(2018,10,29),
              Date.new(2019,02,01)
  ),
  # Cohort.new("CGI Remote September 2018",
  #             Date.new(2018,10,01),
  #             Date.new(2019,01,18)
  # ),
  # Cohort.new("Cognizant January 2019",
  #             Date.new(2019,10,01), Date.today
  # ),
  # Cohort.new("Mixed September 2018",
  #   Date.new(2018,10,01),
  #   Date.new(2018,12,21)
  # ),
  # Cohort.new("November 2018",
  #   Date.new(2019,01,07),
  #   Date.today
  # ),
  # Cohort.new("RELX August 2018",
  #   Date.new(2018,9,3),
  #   Date.new(2018,11,8)
  # ),
]

apiKey = ENV['AIRTABLE_API_KEY']
apiBaseKey = ENV['AIRTABLE_BASE_KEY']

@client = Airtable::Client.new(apiKey)
@registersTable = @client.table(apiBaseKey, "Registers")

@registersRecords = @registersTable.all

registersByCohort = @registersRecords.group_by { |r|
  r["Cohort"][0]
}

cohorts.each do |cohort|

  @xmas = (Date.new(2018,12,24)..Date.new(2019,01,04))

  def working_days_between(startDate, endDate)
    (startDate..endDate).select do |d|
      #weekday
      (1..5).include?(d.wday)
    end.select do |d|
      #xmas period
      !@xmas.include?(d)
    end
  end

  @registeredDates = registersByCohort[cohort.name].map { |r|
    Date.parse(r[:date])
  }.to_set

  totalDates = working_days_between(
    cohort.startDate,
    cohort.endDate
  ).to_set

  # ap "Difference between expected registered for " + cohort.name
  # ap totalDates ^ @registeredDates
  ap "EXPECTED: "
  ap totalDates

  ap "GOT: "
  ap @registeredDates
end
