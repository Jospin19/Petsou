class FileValidator < ActiveModel::EachValidator


  def validate_each(record, attribute, value)
    if value
      if value.respond_to? :path
        unless options[:ext].include? File.extname(value.path).delete('.').to_sym
          record.errors[attribute] << "Is not a valid file. Use file with those extension: #{options[:ext].join(', ')}"
        end
      else
        record.errors[attribute] << (options[:message] || 'Is not a file')
      end
    end
  end
end