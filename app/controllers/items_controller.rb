class ItemsController < ApplicationController
  before_action :set_item, only: %i[ show edit ]
  require 'square'

    # GET all catalog objects from api
    def index
        @items = Item.all
    end

    # GET retrieves a single object from the api
    def show
    end

    #GET the add new product view
    def new
        @product = Item.new
    end

    # GET the edit product view
    def edit
    end
    
    # POST add a product to the catalog
    def create
        response = Item.create item_params

        respond_to do |format|
            if response.success?
                format.html { redirect_to admin_products_path, notice: "Product was successfully created." }
                #format.json { render :show, status: :created, location: @payment }
            else
                format.html { render :new, status: :unprocessable_entity }
                #format.json { render json: @payment.errors, status: :unprocessable_entity }
            end
        end
    end

    # POST update method
    def update
        @product = Item.find params[:id]
        response = @product.update item_params

        respond_to do |format|
            if response
                format.html { redirect_to admin_products_path, notice: "Product was successfully updated." }
                #format.json { render :show, status: :created, location: @payment }
            else
                format.html { render :new, status: :unprocessable_entity }
                #format.json { render json: @payment.errors, status: :unprocessable_entity }
            end
        end
    end

    # DELETE
    def destroy
        response = Admin::Item.delete params[:id]

        respond_to do |format|
            format.html { redirect_to admin_products_path, notice: "Product was successfully created." }
            #format.json { render :show, status: :created, location: @payment }
        end
    end

    private
       # Use callbacks to share common setup or constraints between actions.
        def set_item
            @item = Item.find(params[:id])
        end

        def item_params
           params.require(:item).permit(Item::FIELDS) 
        end
end
