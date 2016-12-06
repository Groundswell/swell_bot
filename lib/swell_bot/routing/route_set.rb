module SwellBot

	module Routing
		class RouteSet

			class RouteCollection

				def initialize()
					@collection = []
				end

				def append( pattern, responder, action, options )
					@collection << { pattern: pattern, responder: responder, action: action, options: options }
					self
				end

				def merge( route_collection )
					@collection.concat( route_collection.collection )
				end

				def collection
					@collection
				end

			end

			class ScopeCollection

				def initialize()
					@collection = {}
				end

				def append( scope, route_set )
					@collection[scope] ||= []
					@collection[scope] << route_set
					self
				end

				def merge( scope_collection )
					scope_collection.collection.each do |key, route_sets|
						route_sets.each do |route_set|
							self.append key, route_set
						end
					end
				end

				def collection
					@collection
				end

			end

			def initialize( args = {} )

				@default_responder = args[:default_responder] || 'SwellBot::TextResponder'
				@request_class = args[:request_class] || 'SwellBot::BotRequest'

				@bot_help = []
				@routes = RouteCollection.new
				@scopes = ScopeCollection.new
			end

			def default_responder
				@default_responder
			end

			def default_args
				{ default_responder: @default_responder, request_class: @request_class }
			end

			def draw(&block)
				# clear! #unless @disable_clear_and_finalize
				eval_block(block)
				# finalize! unless @disable_clear_and_finalize
				nil
			end

			def eval_block(block)
				mapper = Mapper.new( self )
				mapper.instance_exec(&block)
			end

			def bot_help
				@bot_help
			end

			def scopes
				@scopes
			end

			def routes
				@routes
			end

			def merge( route_set )
				@scopes.merge( route_set.scopes )
				@routes.merge( route_set.routes )
			end

			def build_request( message, session, scope, params, args = {} )

			 	if args[:reply_mode] == 'select_reply'

					request = SwellBot::BotRequest.where( user: session.user ).friendly.find( message.to_i )
					reply_to = request.reply_to

				else

					reply_to = args[:reply_to]
					reply_to ||= SwellBot::BotMessage.friendly.find( params[:reply_to_id] ) if params[:reply_to_id].present?

					request = @request_class.constantize.new
					request.reply_to = reply_to
					request.params = params.dup
					request.input = message
					request.scope = scope

				end

				request.thread_id = reply_to.try(:thread_id) || reply_to.try(:id)
				request.status = 'read'
				request.session = session
				request.user = session.user

				route = find_route :reply, request, (request.scope || '').split('/').collect(&:to_sym)

				if route.present?
					request.responder = route[:responder]
					request.action 		= route[:action]
					request.options 	= route[:options].stringify_keys
					request.route_set	= route[:route_set]
				end

				request
			end

			def to_s
				"#{self.class.name} #{@routes.collection.to_json} #{@scopes.collection.keys.to_json}"
			end

			protected
			def find_route( type, request, scope_path )
				route = nil

				current_scope = scope_path.shift

				unless current_scope.blank?

					request_scopes = @scopes.collection[current_scope]

					request_scopes.each do |scope|
						route ||= scope.find_route( type, request, scope_path )
						break if route.present?
					end

				end

				route ||= @routes.collection.find{ |route| ( request.input  =~ route[:pattern] ).present? }

				route.merge( route_set: self ) if route.present?

			end

		end
	end

end