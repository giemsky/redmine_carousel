class CarouselIssueSettings < ActiveSupport::OrderedOptions
  include Redmine::I18n
  
  def self.load(attributes = {})
    issue_settings = new
    return issue_settings unless attributes.is_a?(Hash)

    attributes.symbolize_keys.slice(*allowed_parameters).each do |key, value|
      issue_settings.send("#{key}=", value)
    end
    issue_settings
  end
  
  def self.allowed_parameters
    [:tracker_id, 
     :subject, 
     :description, 
     :priority_id, 
     :category_id,
     :author_id]
  end
  
  def self.required_parameters
    allowed_parameters - Array(:description)
  end
  
  # Translate attribute names for validation errors display
  def self.human_attribute_name(attr)
    l("field_#{attr.to_s.gsub(/_id$/, '')}")
  end
  
  def self.human_name
    l(:label_issue_settings)
  end
  
  def self.self_and_descendants_from_active_record
    Array(self)
  end
  
  def to_hash
    inject(Hash.new) do |output, (key, value)|
      output[key] = value
      output
    end
  end
  
  def errors
    @errors ||= ActiveRecord::Errors.new(self)
  end
  
  def valid?
    errors.clear
    errors.add_on_blank(self.class.required_parameters)
    errors.empty?
  end
  
  def author_id
    super && super.to_i
  end
  
  def priority_id
    super && super.to_i
  end
  
  def tracker_id
    super && super.to_i
  end
  
  def category_id
    super && super.to_i
  end
  
end