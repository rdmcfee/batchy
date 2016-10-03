require 'action_controller'

module Batchy
  class BatchController < ActionController::Base
    respond_to :json
    MAX_REQUESTS = 25
    # TODO what if the app wants auth around this endpoint?

    def index
      unless params[:requests] && params[:requests].is_a?(Array)
        render :json => {:error => "Must pass an array of requests"}, :status => :bad_request and return
      end

      if params[:requests].size > MAX_REQUESTS
        render :json => {:error => "This batch API accepts a maximum of #{MAX_REQUESTS} requests"}, :status => :bad_request and return
      end

      fetcher = Batchy::Fetcher.new(app: Rails.application, requests: params[:requests]).run
      render :json => {:succeeded => fetcher.succeeded, :failed => fetcher.failed, :responses => fetcher.responses}, :status => :ok
    end

  end
end
