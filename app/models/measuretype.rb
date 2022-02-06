# frozen_string_literal: true

class Measuretype < ApplicationRecord
  has_many :measures

  validates :title, presence: true
end
