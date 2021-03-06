require 'av_capture'
require 'Colorscore'
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
        3.times do |i|
          File.open("x_#{i}.jpg", 'wb') { |f| f.write connection.capture }
        end
    end
       histogram =  Colorscore::Histogram.new('x_2.jpg')
       puts "##{histogram.scores.first.last.hex}"
       red = histogram.scores.first.last.red
       green = histogram.scores.first.last.green
       blue = histogram.scores.first.last.blue

       screen_capture_color = LIFX::Color.rgb(red, green, blue)
     light.set_color(screen_capture_color, duration: 1)  # Light#set_color is asynchronous
     sleep 1                                    # Wait for light to finish changing

end
