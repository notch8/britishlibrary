# frozen_string_literal: true

# OVERRIDE IIIF Print v1.0.0

module IiifPrint
  module ImageToolDecorator
    # Add -ping option for efficiency
    def im_identify
      cmd = "identify -ping -format 'Geometry: %G\nDepth: %[bit-depth]\nColorspace: %[colorspace]\nAlpha: %A\nMIME type: %m\n' #{path}"
      `#{cmd}`.lines
    end
  end
end

IiifPrint::ImageTool.prepend(IiifPrint::ImageToolDecorator)
