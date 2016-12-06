module SwellBot
	class JokeResponder < TextResponder

		self.help name: 'Jokes', syntax: 'Tell me a joke', description: 'I can tell funny jokes'

		self.draw do

			respond /^tell me a joke/i, :tell_me_a_joke
			scope :joke_knock_knock do
				respond /^who's there|whos there/i, :who_is_there
				respond :all, :say, text: 'You are suppose to say "Who\'s there?"', scope: 'joke_knock_knock'
			end
			scope :joke_something_who do
				respond :all, :something_who
			end

		end

		JOKES = {
				'canoe' => { who_is_there: "Canoe", something_who: "Canoe help me with my homework?" },
				'orange' => { who_is_there: "Orange", something_who: "Orange you going to let me in?" },
				'needle' => { who_is_there: "Needle", something_who: "Needle little money for the movies." }
		}

		def tell_me_a_joke
			respond_with text: "Knock knock", scope: :joke_knock_knock, emoticon: :smile
		end

		def who_is_there

			joke_key = JOKES.keys.sample
			joke = JOKES[joke_key]

			respond_with text: "#{joke[:who_is_there]}.", scope: :joke_something_who, emoticon: :smile, params: { joke_key: joke_key }
		end

		def something_who
			joke = JOKES[request.params['joke_key']]

			if (request.input =~ /^#{joke[:who_is_there]} who/i).present?
				respond_with text: joke[:something_who], emoticon: :laughing
				respond_with text: 'LMFAO!', emoticon: :laughing
			else
				respond_with text: "You are suppose to say \"#{joke[:who_is_there]} who?\"", scope: request.scope, params: { joke_key: request.params['joke_key'] }
			end

		end

	end
end