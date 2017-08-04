# encoding: UTF-8

require 'uri'
require 'faraday'

module Prometheus
  # Client is a ruby implementation for a Prometheus compatible api_client.
  module ApiClient
    DEFAULT_HOST = 'localhost'.freeze
    DEFAULT_SCHEME = 'http'.freeze
    DEFAULT_PORT = 9090
    DEFAULT_PATH = '/api/v1/'.freeze
    DEFAULT_CREDENTIALS = {}
    DEFAULT_OPTIONS = {}

    # Returns a default client object
    def self.client(
      scheme = DEFAULT_SCHEME, host = DEFAULT_HOST, port = DEFAULT_PORT,
      path = DEFAULT_PATH, credentials = DEFAULT_CREDENTIALS,
      options = DEFAULT_OPTIONS)

      Faraday.new(
        prometheus_args(scheme, host, port, path, credentials,options)
      )
    end

    def self.prometheus_uri(scheme, host, port, path)
      builder = {
        http: URI::HTTP,
        https: URI::HTTPS,
      }[scheme.to_sym]

      builder.build(
        host: host,
        port: port,
        path: path,
      )
    end

    def self.prometheus_args(scheme, host, port, path, credentials, options)
      {
        url: prometheus_uri(scheme, host, port, path).to_s,
        proxy: if options[:http_proxy_uri]
                 options[:http_proxy_uri]
               end,
        ssl: if options[:verify_ssl]
               {
                 verify: options[:verify_ssl] != OpenSSL::SSL::VERIFY_NONE,
                 cert_store: options[:ssl_cert_store],
               }
             end,
        headers: if credentials[:token]
                   {
                     Authorization: "Bearer " + credentials[:token],
                   }
                 end,
        request: {
          open_timeout: 2,
          timeout: 5,
        },
      }
    end
  end
end
