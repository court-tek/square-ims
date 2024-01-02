class Admin::ProductsController < ApplicationController
    require 'square'
    layout 'admin'

    # GET all catalog objects from api
    def index
        @products = Admin::Product.all
    end

    # GET retrieves a single object from the api
    def show
    end

    #GET the add new product view
    def new
        @product = Admin::Product.new
    end

    # GET the edit product view
    def edit
        @product = Admin::Catalog.find params[:id]
    end
    
    # POST add a product to the catalog
    def create
        response = Admin::Product.create catalog_params

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
        @product = Admin::Catalog.find params[:id]
        response = @product.update catalog_params, return_response: true

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

    # DELETE
    def destroy
        response = Admin::Catalog.delete params[:id]

        respond_to do |format|
            format.html { redirect_to admin_products_path, notice: "Product was successfully created." }
            #format.json { render :show, status: :created, location: @payment }
        end
    end

    private
        def catalog_params
           params.require(:product).permit(Admin::Product::FIELDS) 
        end

end
