class Resource < ApplicationRecord
  has_one_base64_attached :image

  validates :name, presence: true
  validates :image, attached: true

  include Base64DataAttachable
  include RemoteUrlAttachable
end
