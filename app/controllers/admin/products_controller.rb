class Admin::ProductsController < ApplicationController
    require 'square'
    layout 'admin'

    # GET all catalog objects from api
    def index
        @catalog = retrieve_catalog_objects
    end

    # the add new product view
    def new
    end
    
    # add a product to the catalog
    def create
        @catalog = create_catalog_product(params[:id], params[:name], params[:description], params[:price_amount].to_i)

        respond_to do |format|
            if @catalog.success?
                format.html { redirect_to admin_products_path, notice: "Product was successfully created." }
                #format.json { render :show, status: :created, location: @payment }
            else
                format.html { render :new, status: :unprocessable_entity }
                #format.json { render json: @payment.errors, status: :unprocessable_entity }
            end
        end
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
                    idempotency_key: SecureRandom.uuid(),
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
                            item_id: "##{id}",
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
                            item_id: "##{id}",
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

                if catalog.success?
                    return catalog.data
                elsif catalog.error?
                    warn catalog.errors
                end
                  
        end
end
