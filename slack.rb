class SlackBot
  puts "when is my slack bot created?"
  Slack.configure do |config|
    config.token = ENV["SLACK_API_TOKEN"]
  end

  def postMessageToSlack(message)
    @slackClient = Slack::Web::Client.new
    puts "slack client?"
    puts @slackClient
    @slackClient.chat_postMessage(channel: '#lindsey-test', text: message, as_user: true)
    @slackClient
  end
end
