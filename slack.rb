class SlackBot
  puts "when is my slack bot created?"
  Slack.configure do |config|
    config.token = ENV["SLACK_API_TOKEN"]
  end

  def postMessageToSlack(message)
    @slackClient = Slack::Web::Client.new
    @slackClient.chat_postMessage(channel: '#apprs-coaching', text: message, as_user: true)
    @slackClient
  end
end
