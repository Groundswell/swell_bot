module SwellBot
	class GreetingsResponder < TextResponder

		def say_hi

			respond_with :render
		end

		self.draw do
			respond /^hi|hello|hey|wassup|heyo|howdy/i, :say_hi
		end

	end
end