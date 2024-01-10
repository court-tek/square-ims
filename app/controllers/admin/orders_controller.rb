class Admin::OrdersController < ApplicationController
    require 'square'
    layout 'admin'

    # GET all catalog objects from api
    def index
        @orders = Admin::Order.all
    end

    # GET retrieves a single object from the api
    def show
    end

    #GET the add new product view
    def new
        @order = Admin::Order.new
    end

    # # GET the edit product view
    # def edit
    #     @order = Admin::Product.find params[:id]
    # end

    # # POST add a product to the catalog
    def create
        response = Admin::Order.create order_params

        respond_to do |format|
            if response.success?
                format.html { redirect_to admin_dashboard_index_path, notice: "Order was successfully created." }
                #format.json { render :show, status: :created, location: @payment }
            else
                format.html { render :new, status: :unprocessable_entity }
                #format.json { render json: @payment.errors, status: :unprocessable_entity }
            end
        end
    end

    # # POST update method
    # def update
    #     @order = Admin::Order.find params[:id]
    #     response = @order.update catalog_params

    #     respond_to do |format|
    #         if response
    #             format.html { redirect_to admin_products_path, notice: "Product was successfully updated." }
    #             #format.json { render :show, status: :created, location: @payment }
    #         else
    #             format.html { render :new, status: :unprocessable_entity }
    #             #format.json { render json: @payment.errors, status: :unprocessable_entity }
    #         end
    #     end
    # end

    # # DELETE
    # def destroy
    #     response = Admin::Order.delete params[:id]

    #     respond_to do |format|
    #         format.html { redirect_to admin_orders_path, notice: "Order was successfully created." }
    #         #format.json { render :show, status: :created, location: @payment }
    #     end
    # end

    private
    # # Use callbacks to share common setup or constraints between actions.
    #     def set_order
    #         @order_id = Page.find(params[:id])
    #     end

        def order_params
            params.require(:order).permit(Admin::Order::FIELDS) 
        end
end
