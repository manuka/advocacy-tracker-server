# frozen_string_literal: true

class ResourcesController < ApplicationController
  before_action :set_and_authorize_resource, only: [:show, :update, :destroy]

  # GET /resources
  def index
    @resources = policy_scope(base_object).order(created_at: :desc)
    authorize @resources

    render json: serialize(@resources)
  end

  # GET /resources/1
  def show
    @res = policy_scope(base_object).find(params[:id])
    render json: serialize(@res)
  end

  # POST /resources
  def create
    @res = Resource.new
    @res.assign_attributes(permitted_attributes(@res))
    authorize @res

    if @res.save
      render json: serialize(@res), status: :created, location: @res
    else
      render json: @res.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /resources/1
  def update
    @res = policy_scope(base_object).find(params[:id])
    if params[:resource][:updated_at] && DateTime.parse(params[:resource][:updated_at]).to_i != @res.updated_at.to_i
      return render json: '{"error":"Record outdated"}', status: :unprocessable_entity
    end
    if @res.update!(permitted_attributes(@res))
      set_and_authorize_resource
      render json: serialize(@res)
    end
  end

  # DELETE /resources/1
  def destroy
    @res = policy_scope(base_object).find(params[:id])
    @res.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_resource
    @res = policy_scope(base_object).find(params[:id])
    authorize @res
  end

  def base_object
    Resource
  end

  def serialize(target, serializer: ResourceSerializer)
    super
  end
end
