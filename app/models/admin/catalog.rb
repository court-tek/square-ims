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
    

    # callbacks
    define_model_callbacks :update, :save

    class << self 
        def find(idempotency_key)
            catalog = API.retrieve idempotency_key: idempotency_key
            raise KeyError, "no customer found for idempotency key `#{id}`" unless customer.success?

            new customer.data.objects
        end
        # def save
        #     run_callbacks :save do 
        #         return false unless valid?

        #         # update
        #         if @persisted 
        #             return begin
        #             update changes.transform_values(&:last)
        #             rescue StandardError
        #                 false
        #             end
        #         end

        #         #create
        #         response = self.class.create changes.transform_values(&:last)
        #         raise response.errors.inspect if response.error?

        #         self.attributes = response.data

        #         self
        #     end
        # end
        
        # def save!
        #     run_callbacks :save do 
        #         validate!


        #         # update
        #         return update changes.transform_values(&:last) if @persisted

        #         #create
        #         response = self.class.create changes.transform_values(&:last)
        #         raise response.errors.inspect if response.error?

        #         self.attributes = response.data

        #         self
        #     end
        # end

        # def persisted?
        #     @persisted 
        # end

        # def persist!
        #     changes_applied
        #     @persisted = true
        # end

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