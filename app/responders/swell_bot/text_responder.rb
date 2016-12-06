module SwellBot
	class TextResponder < ::ApplicationResponder

		def the_time_is
			"It's #{DateTime.now.strftime('%c')}"
		end

		def say

			scope = options['scope'] if options['scope'].present?
			publish = Time.now + options['publish_in'].to_i if options['publish_in'].present?
			emoticon = options['emoticon'] if options['emoticon'].present?

			text = nil

			if options['text'].present?
				text = options['text']
			elsif options['sample'].present?
				text = options['sample'].split(',').sample.strip
			else
				text = '?'
			end

			respond_with text: text, scope: scope, publish: publish, emoticon: emoticon

		end

	end
end