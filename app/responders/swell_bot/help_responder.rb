module SwellBot

	class HelpResponder < ::ApplicationResponder

		self.draw do

			respond /^help\s*$/, :what_can_i_do

		end

		def what_can_i_do
			@bot_help = request.route_set.bot_help

			respond_with :render
		end

	end

end