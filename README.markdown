# sphero

* http://github.com/tenderlove/sphero

## DESCRIPTION:

A ruby gem for controlling your Sphero ball.  Sends commands over the TTY
provided by the bluetooth connection.

## FEATURES/PROBLEMS:

* You need a Sphero

## SYNOPSIS:

```ruby
s = Sphero.new "/dev/tty.Sphero-PRG-RN-SPP"
s.ping

# Roll 0 degrees, speed 125
s.roll(125, 0)

# Turn 360 degrees, 30 degrees at a time
0.step(360, 30) { |h|
  h = 0 if h == 360

  # Set the heading to h degrees
  s.heading = h
  sleep 1
}
sleep 1
s.stop
```

## REQUIREMENTS:

* A Sphero ball connected to your computer

## INSTALL:

* gem install sphero

## LICENSE:

(The MIT License)

Copyright (c) 2012 Aaron Patterson

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
