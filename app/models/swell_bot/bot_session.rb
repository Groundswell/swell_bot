module SwellBot
	class BotSession < ActiveRecord::Base
		self.table_name = 'bot_sessions'

		belongs_to :user
		has_many :bot_messages

	end
end