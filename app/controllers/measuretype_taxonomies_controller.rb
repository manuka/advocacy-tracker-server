class MeasuretypeTaxonomiesController < ApplicationController
  # GET /measuretype_taxonomies/:id
  def show
    @measuretype_taxonomy = policy_scope(base_object).find(params[:id])
    authorize @measuretype_taxonomy
    render json: serialize(@measuretype_taxonomy)
  end

  # GET /measuretype_taxonomies
  def index
    @measuretype_taxonomies = policy_scope(base_object).all
    authorize @measuretype_taxonomies
    render json: serialize(@measuretype_taxonomies)
  end

  private

  def base_object
    MeasuretypeTaxonomy
  end

  def serialize(target, serializer: MeasuretypeTaxonomySerializer)
    super
  end
end
