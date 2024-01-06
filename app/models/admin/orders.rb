class Admin::Order
    include ActiveModel::Attributes
    include ActiveModel::Dirty
    include ActiveModel::Serializers::JSON
    include ActiveModel::Model

    extend Enumerable

    # Api client
    API = Square::Client.new(access_token: ENV.fetch('SQUARE_ACCESS_TOKEN'), environment: 'sandbox')

    # Fields
    IMMUTABLE_FIELDS = %i[created_at updated_at].freeze
    FIELDS = %i[id version name description amount].freeze
end