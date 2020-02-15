class Resource < ApplicationRecord
  has_one_base64_attached :image

  validates :name, presence: true

  validates :image, attached: true
  # validates :image, data_base64_uri: true
end
