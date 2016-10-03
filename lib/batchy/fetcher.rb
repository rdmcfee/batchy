require 'httparty'
require 'uri'

module Batchy
  class Fetcher
    include HTTParty

    class InvalidBatchUrlError < StandardError; end

    # FIXME REMOVE
    DUMMY_REQUESTS =  [
      {:method => "get", :url => "http://www.google.com"},
      {:method => "get", :url => "http://www.google.ca"},
    ]

    # for now let's only allow this to make JSON calls
    format :json

    attr_accessor :responses, :succeeded, :failed

    def initialize(app: nil, requests: DUMMY_REQUESTS)
       # maybe this is being used outside of a rails app for some reason (like me testing).
       # Let's not require that an app is passed.
      @app = app
      @requests = requests
      @responses = []
      @succeeded = 0
      @failed = 0
    end

    def run
      response_threads = @requests.map do |request|
        async_perform(request)
      end

      # HTTParty responses
      response_threads.each { |thr| thr.join }

      # this needs to occur in a threadsafe manner and I want to respect the
      # original order of the requests. Would be slightly faster to use
      # a threadsafe shared variable and store the response there within each thread.
      @responses = response_threads.map(&:value)

      # return self for convenience
      self
    end

    private

    def validate(request)
      raise InvalidBatchUrlError.new("URL is required.") unless request[:url].present?
      # commenting this out for now because engine paths are 
      # not considered by recognize_path and so this will throw 404s.
      # if @app.present?
      #   raise InvalidBatchUrlError.new("No matching path for this application.") unless Rails.application.routes.recognize_path(request[:url])
      #   unless Rails.env.development?
      #     raise InvalidBatchUrlError.new("The requested host does not belong to this application") unless ::SITENAME.split(":").first == URI.parse(request[:url]).host # todo check port as well...?
      #   end
      # end
    end

    # returns thread
    def async_perform(request)
      Thread.new do
        begin
          validate(request)
          response = self.class.send(request[:method].to_sym, request[:url], :query => request[:params], :body => request[:body])
          format(request, response)
        rescue InvalidBatchUrlError => e
          {
            :original_request => request,
            :success => false,
            :error => "Invalid URL. #{e.message}",
          }
        # we use a horribly old version of HTTParty where exceptions
        # don't inherit from their base exception class
        # so I pretty much have to rescue everything here.
        rescue Exception => e
          # horrible hack to see if HTTParty exception
          # re-raise if not
          raise e unless e.class.parent == HTTParty
          {
            :original_request => request,
            :success => false,
            :error => "Exception when executing request: #{e.message}",
          }
        ensure
          # Atomic in MRI. Could fail in other interpreters.
          # note, ensure block's return value is discareded.
          if response && response.success?
            @succeeded += 1
          else
            @failed += 1
          end
        end
      end
    end

    def format(request, response)
      {
        :original_request => request,
        :success => response.success?,
        :code => response.code,
        :body => JSON.parse(response.body),
      }
    end

  end
end
