class Caption < ApplicationRecord
  validates :url, presence: true
  validates :text, presence: true
  validates :caption_url, presence: true
end
