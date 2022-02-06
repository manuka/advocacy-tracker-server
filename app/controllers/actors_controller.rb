# frozen_string_literal: true

class ActorsController < ApplicationController
  before_action :set_and_authorize_actor, only: [:show, :update, :destroy]

  # GET /actors
  def index
    @actors = policy_scope(base_object).order(created_at: :desc).page(params[:page])
    authorize @actors

    render json: serialize(@actors)
  end

  # GET /actors/1
  def show
    render json: serialize(@actor)
  end

  # POST /actors
  def create
    @actor = Actor.new
    @actor.assign_attributes(permitted_attributes(@actor))
    authorize @actor

    if @actor.save
      render json: serialize(@actor), status: :created, location: @actor
    else
      render json: @actor.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /actors/1
  def update
    if params[:actor][:updated_at] && DateTime.parse(params[:actor][:updated_at]).to_i != @actor.updated_at.to_i
      return render json: '{"error":"Record outdated"}', status: :unprocessable_entity
    end
    if @actor.update!(permitted_attributes(@actor))
      set_and_authorize_actor
      render json: serialize(@actor)
    end
  end

  # DELETE /actors/1
  def destroy
    @actor.destroy
  end

  private

  def base_object
    Actor
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_and_authorize_actor
    @actor = policy_scope(base_object).find(params[:id])
    authorize @actor
  end

  def serialize(target, serializer: ActorSerializer)
    super
  end
end
