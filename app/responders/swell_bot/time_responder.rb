module SwellBot
	class TimeResponder < ::ApplicationResponder

		self.help name: 'Time', syntax: 'what time is it OR /time', description: 'I can tell you the time'

		self.draw do
			respond /^what\stime\sis\sit|\/time/i, :the_time_is
		end

		def the_time_is
			respond_with text: "It's #{DateTime.now.strftime('%c')}"
		end

	end
end