class InstagramCaption < ApplicationRecord
  TYPES = %w[image color gradient].freeze

  alias_attribute :type, :type_name

  validates :text, presence: true
  validates :type_name, presence: true, inclusion: { in: TYPES }
  validates :url, presence: true, if: :image?

  def image?
    type_name == "image"
  end
end
