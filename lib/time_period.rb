class TimePeriod < Struct.new(:name, :seconds)
  include Redmine::I18n
  
  def self.all
    [
      new(l(:label_hours),  1.hour),
      new(l(:label_days),   1.day),
      new(l(:label_weeks),  1.week),
      new(l(:label_months), 1.month)
    ]
  end
  
  def self.quantity(total_seconds)
    total_seconds / greatest_divisor(total_seconds).seconds
  end
  
  def self.seconds(total_seconds)
    greatest_divisor(total_seconds).seconds
  end
  
  def self.greatest_divisor(total_seconds)
    all.select{|tp| total_seconds % tp.seconds == 0}.max_by(&:seconds)
  end
  
  private_class_method :greatest_divisor
end