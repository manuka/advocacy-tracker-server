class MeasureResourcesController < ApplicationController
  before_action :set_and_authorize_measure_resource, only: [:show, :destroy]

  # GET /measure_resources
  def index
    @measure_resources = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @measure_resources

    render json: serialize(@measure_resources)
  end

  # GET /measure_resources/1
  def show
    render json: serialize(@measure_resource)
  end

  # POST /measure_resources
  def create
    @measure_resource = MeasureResource.new
    @measure_resource.assign_attributes(permitted_attributes(@measure_resource))
    authorize @measure_resource

    if @measure_resource.save
      render json: serialize(@measure_resource), status: :created, location: @measure_resource
    else
      render json: @measure_resource.errors, status: :unprocessable_entity
    end
  end

  # DELETE /measure_resources/1
  def destroy
    @measure_resource.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_measure_resource
    @measure_resource = policy_scope(base_object).find(params[:id])
    authorize @measure_resource
  end

  def base_object
    MeasureResource
  end

  def serialize(target, serializer: MeasureResourceSerializer)
    super
  end
end
