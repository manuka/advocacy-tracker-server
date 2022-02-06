# frozen_string_literal: true

class Resourcetype < ApplicationRecord
  has_many :resources

  validates :title, presence: true
end
