class InstagramCaption < ApplicationRecord
  TYPES = %w[image color gradient].freeze

  alias_attribute :type, :type_name

  validates :text, presence: true
  validates :type_name, presence: true, inclusion: { in: TYPES }
  validates :caption_url, presence: true
end
