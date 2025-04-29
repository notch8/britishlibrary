# frozen_string_literal: true

# OVERRIDE MiniMagick v4.11.0

module MiniMagick
  class Image
    module InfoDecorator
      def identify
        MiniMagick::Tool::Identify.new do |builder|
          yield builder if block_given?
          builder << '-ping'
          builder << path
        end
      end
    end
  end
end

MiniMagick::Image::Info.prepend(MiniMagick::Image::InfoDecorator)
