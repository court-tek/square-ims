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

    def create
        @catalog = create_catalog_product(params[:id], params[:name], params[:description], params[:price_amount])
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

        def create_catalog_product(id, name, description, price_amount)
            client = self.get_square_client
            result = client.catalog.upsert_catalog_object(
                body: {
                    idempotency_key: ,
                    object: {
                    type: "ITEM",
                    id: "##{id}",
                    item_data: {
                        name: name,
                        description: description,
                        abbreviation: "Co",
                        variations: [
                        {
                            type: "ITEM_VARIATION",
                            id: "#small_coffee",
                            item_variation_data: {
                            item_id: "#coffee",
                            name: "Small",
                            pricing_type: "FIXED_PRICING",
                            price_money: {
                                amount: price_amount,
                                currency: "USD"
                            }
                            }
                        },
                        {
                            type: "ITEM_VARIATION",
                            id: "#large_coffee",
                            item_variation_data: {
                            item_id: "#coffee",
                            name: "Large",
                            pricing_type: "FIXED_PRICING",
                            price_money: {
                                amount: 350,
                                currency: "USD"
                              }
                            }
                          }
                        ]
                      }
                    }
                  }
                )

                if result.success?
                    puts result.data
                elsif result.error?
                    warn result.errors
                end
        end
end
