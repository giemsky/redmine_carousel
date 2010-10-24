class Time
  def self.worktime?(time)
    workday?(time) && (beginning_of_workday(time)..end_of_workday(time)).include?(time)
  end
end