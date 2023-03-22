module Ubiquity
  class ParseDate
    attr_reader :data, :date_field

    def initialize(date_data, date_field_name)
      @date_field = date_field_name
      @data = date_data.split('||')
    end

    def process_dates
      return_values = []
      @data.map do |date|
        return_values << transform_date_group(date)
      end
      return_values
    end

    def self.return_date_part(date, date_part)
      return nil if date.blank?

      date = date.to_date
      if date_part == 'year'
        date.strftime("%Y")
      elsif date_part == 'month'
        date.strftime("%m")
      elsif date_part == 'day'
        date.strftime("%d")
      end
    end

    def self.transform_published_date_group(date_published_hash)
      if date_published_hash.present?
        date = ''
        date_published_hash.each do |date_hash|
          date << date_hash[:date_published_year] if date_hash[:date_published_year].present?
          date << '-' + date_hash[:date_published_month] if date_hash[:date_published_month].present?
          if date_hash[:date_published_day].present? && date_hash[:date_published_month].present?
            date << '-' + date_hash[:date_published_day]
          end
        end
        date
      end
    end

    private

    def transform_date_group(date)
      date_parts =  date.split('-')
      year = "#{date_field}_year"
      month = "#{date_field}_month"
      day = "#{date_field}_day"
      if date_parts.count > 2
        #returns a hash in the form {"date_published_year"=>"2017", "date_published_month"=>"02", "date_published_day"=>"02"}
        Hash[[ [year,  date_parts.first], [month,  date_parts[1]], [day,  date_parts.last]  ]]
      else
        Hash[[ [year,  date_parts.first], [month,  date_parts[1]] ]]
      end
    end
  end
end
