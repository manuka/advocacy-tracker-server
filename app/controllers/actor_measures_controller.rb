class ActorMeasuresController < ApplicationController
  before_action :set_and_authorize_actor_measure, only: [:show, :update, :destroy]

  # GET /actor_measures/:id
  def show
    authorize @actor_measure
    render json: serialize(@actor_measure)
  end

  # GET /actor_measures
  def index
    @actor_measures = policy_scope(base_object).all
    authorize @actor_measures
    render json: serialize(@actor_measures)
  end

  # POST /actor_measures
  def create
    @actor_measure = ActorMeasure.new
    @actor_measure.assign_attributes(permitted_attributes(@actor_measure))
    authorize @actor_measure

    if @actor_measure.save
      render json: serialize(@actor_measure), status: :created, location: @actor_measure
    else
      render json: @actor_measure.errors, status: :unprocessable_entity
    end
  end

  # DELETE /actor_measures/1
  def destroy
    @actor_measure.destroy
  end

  # PATCH/PUT /actor_categories/1
  def update
    if @actor_measure.update!(permitted_attributes(@actor_measure))
      set_and_authorize_actor_measure
      render json: serialize(@actor_measure)
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_actor_measure
    @actor_measure = policy_scope(base_object).find(params[:id])
    authorize @actor_measure
  end

  def base_object
    ActorMeasure
  end

  def serialize(target, serializer: ActorMeasureSerializer)
    super
  end
end
