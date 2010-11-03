class CarouselIssueSettings < ActiveSupport::OrderedOptions
  include Redmine::I18n
  
  REQUIRED_ATTRIBUTES = [
    :tracker_id, 
    :subject, 
    :priority_id, 
    :category_id,
    :author_id
   ]
  
  def initialize(attrs)
    super()
    self.attributes = attrs
  end
  
  def attributes
    inject(Hash.new) do |output, (key, value)|
      output[key] = value
      output
    end
  end
  
  def attributes=(attrs = {})
    attrs.symbolize_keys.each{ |key, value| send("#{key}=", value) }
  end
  
  def errors
    @errors ||= ActiveRecord::Errors.new(self)
  end
  
  def valid?
    errors.clear
    errors.add_on_blank(REQUIRED_ATTRIBUTES)
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
  
end