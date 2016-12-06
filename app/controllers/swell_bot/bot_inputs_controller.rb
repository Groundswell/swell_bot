module SwellBot
	class BotInputsController < ::ApplicationController

		before_filter :get_session

		def index

			@history = BotMessage.published.joins(:session).where( bot_sessions: { user_id: current_user.id } ).order( created_at: :desc )

			if params[:unread]
				@history = @history.where.not(status: BotMessage.statuses['read'])
			else
				@history = @history.page(params[:page]).limit(20)
			end

			@response ||= @history.first if @history.try(:current_page) == 1

			render

			@history.each do |response|
				response.update( status: 'read' ) unless response.read?
			end

		end

		def create
			messages = SwellBot::BotService.request( params[:input], @session, scope: params[:scope], params: params )
			@request = messages.shift
			@responses = messages

			respond_to do |format|

				format.html {
					@history = BotMessage.published.joins(:session).where( bot_sessions: { user_id: current_user.id } ).order( created_at: :desc ).page(params[:page]).limit(20)

					render 'index'

					@history.each do |response|
						response.update( status: 'read' ) unless response.read?
					end
				}
				format.js {
					@responses.each do |response|
						response.update( status: 'read' ) if response.published?
					end
				}

			end

		end

		private
		def get_session

			if cookies[:bot_session]
				@session ||= SwellBot::BotSession.where( id: cookies[:bot_session], user: current_user ).first
			end

			@session ||= SwellBot::BotSession.create( user: current_user )
			cookies[:bot_session] = @session.id

		end

	end
end