class DataBase64UriValidator < ActiveModel::EachValidator
  DATA_BASE64_URI_REGEXP = %r{/^data:.+;base64,.+$/}.freeze

  def validate_each(record, attribute, value)
    return unless DATA_BASE64_URI_REGEXP.match?(value)

    record.errors.add(attribute, :data_base64_uri, options)
  end
end
