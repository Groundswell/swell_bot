module SwellBot
	class BotMessage < ActiveRecord::Base
		self.table_name = 'bot_messages'

		include FriendlyId
		friendly_id :slugger, use: [ :slugged, :history ]

		before_save :set_default_published_at

		belongs_to :user
		belongs_to :session, class_name: 'SwellBot::BotSession', foreign_key: 'bot_session_id'

		belongs_to :reply_to, class_name: 'SwellBot::BotMessage', foreign_key: 'reply_to_id'
		belongs_to :thread, class_name: 'SwellBot::BotMessage', foreign_key: 'thread_id'

		has_many :messages, class_name: 'SwellBot::BotMessage', foreign_key: 'thread_id'
		has_many :replies, class_name: 'SwellBot::BotMessage', foreign_key: 'reply_to_id'


		enum status: { 'hidden' => -1, 'option' => 0, 'unnoticed' => 1, 'unread' => 2, 'read' => 3, 'archived' => 4, 'trash' => 5 }
		enum reply_mode: { 'no_reply' => 0, 'input_reply' => 1, 'select_reply' => 2 }

		def options
			super().with_indifferent_access
		end

		def params
			super().with_indifferent_access
		end

		def publish=(time)
			self.published_at = time
		end

		def self.published
			where('published_at < ?', Time.now).where( status: [self.statuses['unnoticed'], self.statuses['unread'], self.statuses['read']] )
		end

		def published?
			self.published_at < Time.now && ['unnoticed', 'unread', 'read'].include?( self.status )
		end

		def reply_options=( reply_options )
			reply_options.each do |reply_option|
				if attributes.is_a? SwellBot::BotMessage
					reply_option.thread_id = self.thread_id
					reply_option.status = :option
					reply_option.save
					self.replies << reply_option
				else
					self.replies << SwellBot::BotRequest.create( reply_option.merge( status: :option, thread_id: self.thread_id ) )
				end
			end
		end

		protected
		def set_default_published_at
			self.published_at ||= Time.now unless self.option?
		end

		def slugger
			return self.slug || SecureRandom.uuid
		end

	end
end