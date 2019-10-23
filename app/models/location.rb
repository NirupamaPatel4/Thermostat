class Location < ApplicationRecord
  has_many :thermostats, dependent: :destroy
end
