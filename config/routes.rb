SwellBot::Engine.routes.draw do

	resources :bot_inputs

	root to: 'bot_inputs#index'


end
