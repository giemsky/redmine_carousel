module CarouselsHelper
	def	calendar_with_time_for(field_id)
    include_calendar_headers_tags
		image_tag("calendar.png", {:id => "#{field_id}_trigger",:class => "calendar-trigger"}) +
		javascript_tag("Calendar.setup({inputField : '#{field_id}', timeFormat : '24', showsTime : true, ifFormat : '%Y-%m-%d %H:%M', button : '#{field_id}_trigger' });")
	end
end
