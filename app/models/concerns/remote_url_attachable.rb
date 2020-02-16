require 'httparty'

# Allows a model with :image storage attribute to attached a remote URL image
# by downloading it first
module RemoteUrlAttachable
  include ActiveSupport::Concern

  def attach_image_from_url(uri)
    resp = HTTParty.get(uri)

    return unless resp.ok?

    io = StringIO.new(resp.parsed_response)
    image.attach(io: io, filename: name.to_s.parameterize.underscore)
  end
end
