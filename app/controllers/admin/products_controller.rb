class Admin::ProductsController < ApplicationController
    require 'square'
    layout 'admin'

    def index
    end

    def new
    end

    private
    def get_square_client
        access_token = ENV['SQUARE_ACCESS_TOKEN']
    end

    def retrieve_catalog_objects
        client = self.get_square_client
        result = client.catalog.list_catalog

        if result.success?
        puts result.data
        elsif result.error?
        warn result.errors
        end
    end
end
