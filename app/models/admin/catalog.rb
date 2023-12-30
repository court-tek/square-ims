class Admin::Catalog 
    include ActiveModel::Attributes
    include ActiveModel::Dirty
    include ActiveModel::Serializers::JSON
    include ActiveModel::Model

    extend Enumerable

    # Api client
    API = Square::Client.new( access_token: ENV.fetch('SQUARE_ACCESS_TOKEN'), environment: 'sandbox' )

    # fields
    IMMUTABLE_FIELDS = %i[idempotency_key created_at updated_at].freeze
    FIELDS = %i[name description price_amount].freeze

    # attributes
    attribute :idempotency_key, :string
    attribute :name, :string
    attribute :description, :string
    attribute :price_amount, :integer
    
    # stuff
    attr_accessor :persisted

    # callbacks
    define_model_callbacks :update, :save

    class << self 
        def find(idempotency_key)
            catalog = API.catalog.retrieve_catalog_object(
                object_id: idempotency_key
            )
            raise KeyError, "no catalog found for idempotency key `#{idempotency_key}`" unless catalog.success?

            return catalog.data.object
        end
        
        def all
            cursor = nil
            catalog = []

            loop do 
                catalog_list = API.catalog.search_catalog_items(
                    body: {
                        cursor: cursor
                      }
                )
                catalog += catalog_list.data.objects.map do |catalog|
                    return catalog
                end

                return catalog unless cursor
            end
        end

        def create (attributes = OpenStruct.new)
            yield attributes if block_given?
            API.catalog.upsert_catalog_object(
                body: {
                  idempotency_key: "",
                  object: {
                    type: "ITEM",
                    id: "#Cocoa",
                    item_data: {
                      name: "",
                      description: "Hot Chocolate",
                      abbreviation: "Ch",
                      variations: [
                        {
                          type: "ITEM_VARIATION",
                          id: "#Small",
                          item_variation_data: {
                            item_id: "#Cocoa",
                            name: "Small",
                            pricing_type: "VARIABLE_PRICING"
                          }
                        },
                        {
                          type: "ITEM_VARIATION",
                          id: "#Large",
                          item_variation_data: {
                            item_id: "#Cocoa",
                            name: "Large",
                            pricing_type: "FIXED_PRICING",
                            price_money: {
                              amount: nil,
                              currency: "USD"
                            }
                          }
                        }
                      ]
                    }
                  }
                }
              )
              
        end

        def save
            run_callbacks(:save) do 
                return false unless valid?

                # update
                if @persisted 
                    return begin
                    update changes.transform_values(&:last)
                    rescue StandardError
                        false
                    end
                end

                #create
                response = self.class.create changes.transform_values(&:last)
                raise response.errors.inspect if response.error?

                self.attributes = response

                self
            end
        end
        
        def save!
            run_callbacks :save do 
                validate!


                # update
                return update changes.transform_values(&:last) if @persisted

                #create
                response = self.class.create changes.transform_values(&:last)
                raise response.errors.inspect if response.error?

                self.attributes = response.data

                self
            end
        end

        def persisted?
            @persisted 
        end

        def persist!
            changes_applied
            @persisted = true
        end

        # def update!(attributes)
        #     run_callbacks :update do 
                
        #         response = self.class.update idempotency_key, attributes
        #         raise response.errors.inspect if response.error?

        #         self.attributes = response.data

        #         return response if return_response

        #         self
        #     end
        # end
    end
end