class LineCalendar < ActiveRecord::Base

	belongs_to :calendar
	default_scope { order('fecha ASC') }

	validates :dia, presence: true
	validates_date :fecha, :between => [Date.current.year.to_s+'-01-01', ((Date.current.year)+1).to_s+'-12-31']

end
