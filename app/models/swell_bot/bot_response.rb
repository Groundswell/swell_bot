module SwellBot
	class BotResponse < BotMessage

		def emoticon=(val)
			if val.is_a?(Symbol) || ( val =~ URI::regexp(%w(http https)) ).blank?
				val = SwellBot.bot_emoticons[val]
			end

			super( val )
		end

		def output=(output)
			self.content = output
		end

		def output
			self.content
		end

		def to_s
			self.content
		end

	end
end