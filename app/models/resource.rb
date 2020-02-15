class Resource < ApplicationRecord
  has_one_base64_attached :image

  validates :name, presence: true
  validates :image, attached: true

  DATA_BASE64_URI_REGEXP = /^data:(?<type>.+);base64,(?<data>.+)$/.freeze

  def attach_image(data)
    return unless valida_image_data?(data)

    image.attach(data: data, filename: image_filename(data))
  end

  private

  def valida_image_data?(data)
    if DATA_BASE64_URI_REGEXP.match?(data)
      true
    else
      errors.add(:image, :invalid_data_base64_uri)
      false
    end
  end

  def image_filename(data)
    "#{name.to_s.parameterize.underscore}.#{get_extension_from_data(data)}"
  end

  def get_extension_from_data(data)
    matches = DATA_BASE64_URI_REGEXP.match(data)
    return '' if matches.nil? || matches[:type].blank?

    matches[:type].split('/').last
  end
end
