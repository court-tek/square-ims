class Admin::Catalog 
    include ActiveModel::Attributes
    include ActiveModel::Dirty
    include ActiveModel::Serializers::JSON
    include ActiveModel::Model

    extend Enumerable

    # Api client
    API = Square::Client.new( access_token: ENV.fetch('SQUARE_ACCESS_TOKEN'), environment: 'sandbox' )

    # fields
    IMMUTABLE_FIELDS = %i[id created_at updated_at].freeze
    FIELDS = %i[name description amount idempotency_key].freeze

    # attributes
    attribute :id, :string
    attribute :created_at, :datetime
    attribute :updated_at, :datetime
    attribute :amount, :integer

    (FIELDS - %i[amount]).each do |field|
      attribute field, :string, default: ''
    end
    
    # stuff
    attr_accessor :persisted

    # 
    FIELDS.each do |field|
      define_method "#{field}=" do |value|
        public_send "#{field}_will_change!"
        super(value)
      end
    end

    attribute_method_suffix '?'

    define_attribute_methods *FIELDS

    def attribute?(attr)
      public_send(attr).present?
    end

    # callbacks
    define_model_callbacks :update, :save

    after_save :persist!
    after_update :persist!

    def initialize(attributes = {})
        super()

        @persisted = false
        assign_attributes(attributes) if attributes
        yield self if block_given?

        self
    end
    
    class << self 
        def find(idempotency_key)
            catalog = API.catalog.retrieve_catalog_object(
                object_id: idempotency_key
            )
            raise KeyError, "no catalog found for idempotency key `#{idempotency_key}`" unless catalog.success?

            return catalog.data.object
        end
        
        def all
            loop do 
                catalog_list = API.catalog.list_catalog
                  if catalog_list.success?
                    return catalog_list.data.objects
                  elsif catalog_list.error?
                    warn catalog_list.errors
                  end
            end
        end

        def create (attributes = OpenStruct.new)
            yield attributes if block_given?
            catalog = API.catalog.upsert_catalog_object(
              body: {
                    :idempotency_key => attributes["idempotency_key"],
                    object: {
                    type: "ITEM",
                    id: "#shoes",
                    item_data: {
                        :name => attributes["name"],
                        :description => attributes["description"],
                        abbreviation: "Co",
                        variations: [
                        {
                            type: "ITEM_VARIATION",
                            id: "#small_coffee",
                            item_variation_data: {
                            item_id: "#shoes",
                            name: "Small",
                            pricing_type: "FIXED_PRICING",
                            price_money: {
                                :amount => attributes["amount"],
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
              puts catalog.data
            elsif catalog.error?
              warn catalog.errors
            end
        end

        def update (id, attributes)
            catalog = API.catalog.upsert_catalog_object(
              body: {
                    idempotency_key: SecureRandom.uuid(),
                    id: id,
                    object: {
                      type: "ITEM",
                      version: 1704134044939,
                    id: id,
                    item_data: {
                        name: "Yeezy Boost 2000",
                        description: attributes["description"],
                        abbreviation: "Co",
                        variations: [
                        {
                            type: "ITEM_VARIATION",
                            id: "#small_coffee",
                            item_variation_data: {
                            item_id: id,
                            name: "Small",
                            pricing_type: "FIXED_PRICING",
                            price_money: {
                                amount: 330,
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
              puts catalog.data
            elsif catalog.error?
              warn catalog.errors
            end
        end

        def each
          all.each { |catalog| yield catalog }
        end
      end

          def update (attributes, return_response: false)
            run_callbacks :update do
              response = self.class.update id, attributes
              return false if response.error?

              self.attributes

              self
            end
          end

          def update!(attributes)
            run_callbacks :update do 
                
                response = self.class.update id, attributes
                raise response.errors.inspect if response.error?

                self.attributes

                self
            end
          end

          def save
            run_callbacks :save do 
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

                self.attributes

                self
            end
          end
        
        def save!
            run_callbacks(:save) do 
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
end