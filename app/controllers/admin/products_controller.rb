class Admin::ProductsController < ApplicationController
    require 'square'
    layout 'admin'

    # GET all catalog objects from api
    def index
        @catalog = retrieve_catalog_objects
    end

    # 
    def new
    end

    private
        # connects to the square client api
        def get_square_client
            access_token = ENV.fetch('SQUARE_ACCESS_TOKEN')
            client = Square::Client.new(
                access_token: access_token,
                environment: 'sandbox'
            )

            return client
        end

        # retrieve all catalog objects with no preference
        def retrieve_catalog_objects
            client = self.get_square_client
            result = client.catalog.list_catalog

            if result.success?
                return result.data.objects
            elsif result.error?
                warn result.errors
            end
        end
end
