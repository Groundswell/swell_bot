module SwellBot

	module Routing
		class Mapper



			class Mapping

			end

			module Mount

				def help( args = {} )
					@set.bot_help.append(args)
				end

				def mount(*mounting)
					options = mounting.extract_options!.dup

					klass = mounting[0].to_s
					method = mounting[1] || :bot_routes

					@set.bot_help.concat(klass.constantize.try(:bot_help) || [])

					route_set = klass.constantize.try(method)

					@set.bot_help.concat(route_set.bot_help)

					if options[:at]
						@set.scopes.put options[:at], route_set
					else
						@set.merge route_set
					end

					nil
				end

				private

			end

			module Respond

				def respond(*route)
					options = route.extract_options!.dup

					raise "error" if route.count < 2

					if route.count > 0
						pattern = route[0]
						pattern = /^.*$/ if pattern == :all
					end

					if route[1].is_a?( String ) && route[1].include?('#')
						route[1] = route[1].split('#')
						responder = route[1][0]
						action = route[1][1]
					elsif route[1].is_a? Symbol
						responder = @set.default_responder

						action = route[1]
					else
						raise "error"
					end

					@set.routes.append( pattern, responder, action, options )

					nil
				end

				private

			end

			module Scope

				def scope(*scoping, &block)
					options = scoping.extract_options!.dup
					scope = scoping.first

					scoped_set = SwellBot::Routing::RouteSet.new( @set.default_args )

					scoped_set.draw &block

					@set.scopes.append scope, scoped_set

					nil
				end

				private

			end



			def initialize(set) #:nodoc:
				@set = set
			end

			include Respond
			include Mount
			include Scope

		end
	end

end