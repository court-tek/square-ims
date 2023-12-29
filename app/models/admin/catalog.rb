class Admin::Catalog 
    include ActiveModel::Attributes

    attribute :idempotency_key, :string
    attribute :price_amount, :integer

    # access_token = ENV.fetch('SQUARE_ACCESS_TOKEN')Ò
    # self.site = Square::Client.new( access_token: access_token, environment: 'sandbox )
end