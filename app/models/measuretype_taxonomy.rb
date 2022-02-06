class MeasuretypeTaxonomy < ApplicationRecord
  belongs_to :measuretype
  belongs_to :taxonomy
end
