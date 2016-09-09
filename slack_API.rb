require "slack"
require "open-uri"
require "json"
require "yaml"


val = YAML.load_file('key.yml')

def user_search(val, data)
	response = open("https://slack.com/api/users.list?token=#{val['token']}")
	users = JSON.parse(response.read)

	users['members'].each do |user|
		return user['name'] if user["id"] == data['user']
	end
end

Slack.configure { |config| config.token = val['token'] }
client = Slack.realtime

client.on :message do |data|
	unless data['subtype'] == 'bot_message'
		Slack.chat_postMessage(
			text: "@#{user_search(val, data)} #{data['text']}",
			username: val['name'] ||= 'わふー',
			icon_emoji: val['pic'] ||= ':rube:',
			channel: data['channel'],
			link_names: true,
			mrkdwn: true
		)
	end
end

client.start
