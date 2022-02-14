class MeasureMeasuresController < ApplicationController
  before_action :set_and_authorize_measure_measure, only: [:show, :update, :destroy]

  # GET /measure_measures
  def index
    @measure_measures = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @measure_measures

    render json: serialize(@measure_measures)
  end

  # GET /measure_measures/1
  def show
    render json: serialize(@measure_measure)
  end

  # POST /measure_measures
  def create
    @measure_measure = base_object.new
    @measure_measure.assign_attributes(permitted_attributes(@measure_measure))
    authorize @measure_measure

    if @measure_measure.save
      render json: serialize(@measure_measure), status: :created, location: @measure_measure
    else
      render json: @measure_measure.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /measure_measures/1
  def update
    if @measure_measure.update!(permitted_attributes(@measure_measure))
      render json: serialize(@measure_measure)
    end
  end

  # DELETE /measure_measures/1
  def destroy
    @measure_measure.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_measure_measure
    @measure_measure = policy_scope(base_object).find(params[:id])
    authorize @measure_measure
  end

  def base_object
    MeasureMeasure
  end

  def serialize(target, serializer: MeasureMeasureSerializer)
    super
  end
end
