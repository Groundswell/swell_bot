module SwellBot

	class AsyncResponderWorker
		include Sidekiq::Worker
		sidekiq_options retry: 0, :queue => :critical

		def perform( bot_request_id, responder_class, args = '{}' )
			# puts "AsyncResponderWorker#perform #{bot_request_id}, #{responder_class}, #{args}"

			args_json = '{}'
			args_json = args if args.is_a? String
			args = JSON.parse( args_json ).with_indifferent_access rescue {}

			request = SwellBot::BotRequest.find( bot_request_id )

			responses = SwellBot::Responder.build_response!( request, controller: self, action: args[:async] )

			if args[:callback]

				args[:callback].constantize.perform_async( responses.collect(&:id), args )

			end

		end
	end

end