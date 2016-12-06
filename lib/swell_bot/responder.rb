module SwellBot

	class Responder < AbstractController::Base

		include AbstractController::Rendering

		include AbstractController::Logger
		include AbstractController::Helpers
		include AbstractController::Translation
		include AbstractController::AssetPaths
		include AbstractController::Callbacks

		include ActionView::Layouts

		self.view_paths = [ 'app/views', "#{SwellBot::Engine.root}/app/views" ]

		helper_method :request, :response, :current_user, :session, :params, :input

		attr_accessor :request
		attr_accessor :scope
		#attr_accessor :response

		def initialize( request, args = {} )

			@args = args

			@response_class = args[:response_class] || 'SwellBot::BotResponse'
			@controller = args[:controller]

			response = SwellBot::BotService.respond( nil, reply_to: request, session: request.session, response_class: @response_class )

			@responses = [response]
			#

			self.request = request
		end



		#object methods

		def action_name
			@args[:action] || request.action
		end

		def current_user
			request.user
		end

		def input
			request.input
		end

		def options
			@args[:options] || request.options
		end

		def params
			@args[:params] || request.params
		end

		def record_user_event( args={} )
			if defined?(SwellMedia) && @controller.respond_to?( :record_user_event )

				args[:parent_controller] ||= responder_name
				args[:parent_action] ||= action_name

				args[:event] ||= args[:name] || "#{responder_name.singularize}_#{action_name}"

				return @controller.record_user_event( args )

			else
				return false
			end
		end

		def responder_name
			self.class.name.underscore
		end

		def respond_with(*respond)
			respond_options = respond.extract_options!.dup.with_indifferent_access

			if respond_options[:async] && ( respond_options[:async].is_a?( Symbol ) || respond_options[:async].is_a?( String ) )
				SwellBot::AsyncResponderWorker.perform_async( request.id, self.class.name, respond_options.to_json )
			elsif respond.first == :render
				output = render_to_string
			elsif respond_options[:render]
				output = render_to_string respond_options.delete(:render)
			elsif respond_options[:text]
				output = respond_options.delete(:text)
			end



			unless output.nil?


				@responses.last.update respond_options.merge( content: output )

				response = SwellBot::BotService.respond( nil, reply_to: request, session: request.session, response_class: @response_class )
				@responses << response

			end

			nil

		end

		def response
			@responses.last
		end

		def session
			request.session
		end

		def _build_request

			output = self.send( self.action_name )

			if @responses.blank? && output.is_a?( String )

				response.update content: output

				response = SwellBot::BotService.respond( nil, reply_to: request, session: request.session, response_class: @response_class )
				@responses << response

			end

			@responses.select{ |response| response.persisted? }

		end

		def _process_options(options)
			puts "_process_options #{options.to_json}"
			options[:template] = request.action if options[:template].blank?
			options[:layout] = false if options[:layout].blank?
			puts "_process_options #{options.to_json}"
			options
		end



		#class methods

		def self.bot_routes
			@bot_routes
		end

		def self.bot_help
			@bot_help || []
		end

		def self.build_response( request, args = {} )

			if request.responder.nil?
				nil
			else
				request.responder.constantize.new( request, args )._build_request
			end

		end

		def self.build_response!( request, args = {} )

			responses = self.build_response request, args

			responses.each do | response |
				response.save
			end

			responses

		end

		private

		# def response_body
		# 	@response_body
		# end
		#
		# def response_body=(response_body)
		# 	@response_body = response_body
		# end


		protected

		def async
			async_options = self.options.dup
			with = async_options.delete(:with)
			async_options = async_options.merge( async: with )
			respond_with async_options
		end

		def self.help( args={} )
			@bot_help ||= []
			@bot_help << args
		end

		def self.draw(&block)

			@bot_routes = SwellBot::Routing::RouteSet.new( default_responder: "#{self.name}" )

			@bot_routes.draw(&block)

			nil
		end

	end

end