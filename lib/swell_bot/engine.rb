module SwellBot

	class << self
		@bot_routes = nil

		mattr_accessor :bot_emoticons
		mattr_accessor :bot_icon

		self.bot_emoticons = HashWithIndifferentAccess.new
		self.bot_icon = ''
	end

	def self.bot_routes
		@bot_routes
	end

	# this function maps the vars from your app into your engine
	def self.configure( &block )
		@bot_routes = SwellBot::Routing::RouteSet.new

		yield self
	end


  class Engine < ::Rails::Engine
    isolate_namespace SwellBot

		initializer "swell_bot.set_configs" do |app|
			app.config.autoload_paths += %W(#{Rails.root}/app/responders/**/ #{Rails.root}/app/responders/)
		end

		initializer "swell_bot.set_bot_routes" do |app|
			require "#{Rails.root}/config/bot_routes"
		end

		def self.bot_routes

			route = SwellBot::Routing::RouteSet.new

			route.draw do
				mount SwellBot::HelpResponder
				mount SwellBot::GreetingsResponder
				mount SwellBot::TimeResponder
				mount SwellBot::JokeResponder
			end

			route

		end

  end
end
