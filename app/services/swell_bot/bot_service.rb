module SwellBot

	class BotService

		def self.request( message, session, args = {} )

			request = SwellBot.bot_routes.build_request( message, session, args[:scope], args[:params], reply_to_id: args[:reply_to_id], reply_mode: args[:reply_mode] )
			request.save

			responses = SwellBot::Responder.build_response( request, (args[:response] || {}) )

			responses.each do | response |
				response.save
			end

			[request].concat( responses )

		end

		def self.respond( message, args = {} )

			response_class = ( args.delete(:response_class) || 'SwellBot::BotResponse' ).constantize

			if args[:session].present?
				session = args.delete(:session)
			elsif args[:session_id].present?
				session = SwellBot::BotSession.find( args.delete(:session_id) )
			else
				session = SwellBot::BotSession.where( user_id: (args.delete(:user_id) || args.delete(:user).try(:id)) ).last

				session ||= SwellBot::BotSession.create( user: args[:user] ) if args[:user].present?
				session ||= SwellBot::BotSession.create( user_id: args.delete(:user_id) ) if args[:user_id].present?
			end

			response = response_class.new( session: session, content: message, slug: SecureRandom.uuid )
			response.attributes = args
			response.thread_id = response.reply_to.try(:thread_id) || response.reply_to.try(:id)

			response

		end

		def self.respond!( message, args = {} )

			response = self.respond( message, args )
			response.save

			response

		end

	end

end