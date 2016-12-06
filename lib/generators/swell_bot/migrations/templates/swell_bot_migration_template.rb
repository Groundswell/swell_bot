class SwellBotMigration < ActiveRecord::Migration

	def change

		enable_extension 'hstore'

		create_table :bot_messages do |t|
			t.string			:type
			t.string			:emoticon
			t.references	:user
			t.references	:bot_session
			t.references	:bot_request
			t.text				:content
			t.string			:responder
			t.string			:action
			t.string			:scope
			t.hstore			:options, default: {}
			t.hstore			:params, default: {}
			t.integer  		:status, default: 1
			t.datetime		:published_at
			t.timestamps
		end
		add_index :bot_messages, [:user_id,:published_at,:status], name: 'index_bot_messages_on_user_id_and_published_at'
		add_index :bot_messages, [:bot_session_id,:user_id,:published_at,:status], name: 'index_bot_messages_on_session_and_user_and_published'

		create_table :bot_sessions do |t|
			t.references	:user
			t.hstore			:properties, default: {}
			t.timestamps
		end
		add_index :bot_sessions, [:user_id,:created_at]


	end
end




