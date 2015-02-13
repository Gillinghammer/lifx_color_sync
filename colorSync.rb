require 'av_capture'
require 'rmagick'
require 'color'
require 'lifx'

client = LIFX::Client.lan                  # Talk to bulbs on the LAN
client.discover!
light = client.lights.first

session = AVCapture::Session.new
dev     = AVCapture.devices.find(&:video?)

p dev.name
p dev.video?

100.times do |run|

  session.run_with(dev) do |connection|
    5.times do |i|
      File.open("x_#{i}.jpg", 'wb') { |f|
        f.write connection.capture
      }
      sleep 1
    end
  end

  img =  Magick::Image.read('x_4.jpg').first
  pix = img.scale(1, 1)
  # averageColor = pix.pixel_color(0,0)
  avg_color_hex = pix.to_color(pix.pixel_color(0,0))

  puts avg_color_hex;

  c = Color::RGB.from_html(avg_color_hex[1..-1])

  screen_capture_color = LIFX::Color.rgb(c.red,c.green,c.blue)
  light.set_color(screen_capture_color, duration: 1)  # Light#set_color is asynchronous
  sleep 1                                    # Wait for light to finish changing

end