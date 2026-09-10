class Caption < ApplicationRecord
  validates :url, presence: true
  validates :text, presence: true
end
