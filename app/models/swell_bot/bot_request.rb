module SwellBot
	class BotRequest < BotMessage

		attr_accessor :route_set

		def input=(input)
			self.content = input
		end

		def input
			self.content
		end

		def variant

		end

		def to_s
			self.content
		end

	end
end