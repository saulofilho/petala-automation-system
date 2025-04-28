module V1
  class OrdersController < ApplicationController
    before_action :authenticate_request!
    before_action :set_company, only: %i[index create]
    before_action :set_order, only: %i[show update destroy]

    def index
      render json: @company.orders, each_serializer: OrderSerializer, status: :ok
    end

    def show
      render json: @order, serializer: OrderSerializer, status: :ok
    end

    def create
      @order = @company.orders.build(order_params)
      if @order.save
        render json: { order: OrderSerializer.new(@order) }, status: :created
      else
        render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @order.update(order_params)
        render json: { order: OrderSerializer.new(@order) }, status: :ok
      else
        render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @order.destroy
      head :no_content
    end

    private

    def set_company
      @company = current_user.companies.find(params[:company_id])
    end

    def set_order
      @order = Order.find(params[:id])
      head :forbidden unless @order.company.user_id == current_user.id
    end

    def order_params
      params.require(:order).permit(
        :code, :product, :price, :quantity, :total, :uuid, :ean
      )
    end
  end
end
