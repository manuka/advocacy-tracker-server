class Actortype < ApplicationRecord
  has_many :actors

  validates :title, presence: true
end
