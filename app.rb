load_paths = Dir["./vendor/bundle/ruby/2.6.0/gems/**/lib"]
$LOAD_PATH.unshift(*load_paths)

require 'airtable'
require 'active_support/all'
require 'awesome_print'
require 'slack-ruby-client'
require 'dotenv/load'

Slack.configure do |config|
  config.token = ENV["SLACK_API_TOKEN"]
end

@slackClient = Slack::Web::Client.new
@slackClient.auth_test

def postMessageToSlack(message)
  @slackClient.chat_postMessage(channel: '#lindsey-test', text: message, as_user: true)
end

apiKey = ENV['AIRTABLE_API_KEY']
apiBaseKey = ENV['AIRTABLE_BASE_KEY']

@client = Airtable::Client.new(apiKey)

@cohortsTable = @client.table(apiBaseKey, "Cohorts")

@cohortsRecords = @cohortsTable.all

cohorts = @cohortsRecords.select do |cohort|
    begin
      Date.parse(cohort[:end_date]).future?
    rescue ArgumentError
      false
    end
end

cohorts.each do |cohort|

  @registersTable = @client.table(apiBaseKey, "Registers")
  @registersRecords = @registersTable.select(formula: "Cohort='#{cohort[:name]}'")

  def working_days_between(startDate, endDate)
    (startDate..endDate).select do |d|
      #weekday
      (1..5).include?(d.wday)
    end
  end

  @registeredDates = @registersRecords.map { |r|
    Date.parse(r[:date])
  }.sort { |d1, d2| d1 <=> d2 }.to_set

  totalDates = working_days_between(
    Date.parse(cohort[:start_date]),
    Date.today
  ).to_set

  diff = totalDates - @registeredDates.sort { |d1, d2| d1 <=> d2 }.to_set

  if diff.empty?
    postMessageToSlack("All registers up to date for #{cohort.name}. Great job, coach!")
  else
    postMessageToSlack("Missing registration days for #{cohort.name}")
    postMessageToSlack(diff)
  end
end
