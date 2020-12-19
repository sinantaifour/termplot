require 'minitest/autorun'
require 'termlot'
require 'base64'
require 'zlib'

class CanvasTest < Minitest::Test

  def setup
    x = 0.step(3 * Math::PI, by: 3 * Math::PI / 30).to_a
    @sin = x.map { |v| (Math.sin(v) + 1) / 2 }
    @cos = x.map { |v| (Math.cos(v) + 1) / 2 }
    @x = x.map { |v| v / (3 * Math::PI) }
  end

  REFS = {
    :ascii => <<~EOS,
      eJytl1kOgyAQht85heGliZnEe6hHaNAr9P4vdakL8M8CdpJWA8P/MSwj+BAm
      ai6j26/QaArB+zBMFjm3/s1DBSbDdvPx6g1ybn/s6NS/oDs37IkW5dzx0j4K
      mtq05K20OMGPyDlX1bvADVWTcUuZfIIXL0LDY+gN4q5FM1MegzfTJsbM1WpS
      cA1ZUhfqEnD5PMst+NoNPCqeIyj72Ueax8V6rt6lpciTN7SPYuPWdgYu28/C
      WBz2soKb3s7tLE54wQIw9kTjYOJiPXJIcLYJdsrCEskoYuN2NsbLdAeDLeSS
      LQ98GbCuWpZqKFv+DFhNJLmS/D3JNikH1lKhmjg0MguGMdVzMzIPFlJYDTfV
      E8CYvB4YQBa0LLXoMyCBmXmui3e1eyQiuKHhn9yILINBJqk/EsatNXByK6AW
      nNRLukJH0Cr4jqZnp/5IxABe0G3YLmTgclfTE/IhkPsCkaLU9w==
    EOS
    :dot => <<~EOS,
      eJyll0sCwyAIRPeewh07D5D7H6yJbRrFAQfiIrUG5slg+hFprdVnXHP5vQbH
      KSTCypV+lQRm5co9Y+RKIJbEcnI3uIeKuqnfs1hGrkyh2bFw93IP+AUZcM9x
      cGAxQgm7rTRUyV+uTMv+Ji2uuTfPwxmcIXspDlmB42Q/wSZ38OhVsM+7cLPP
      uuJgzfg8M3IrOEQmYo0QAA48z9QecRAAYzJaI71BYa2gJpE1oweY/gxDFZPk
      /cHy5DCYMZHnQrIB3pMjXES2wPhEDFNw3+vPEm6C/TbH6kVkE+yS49yFbIM9
      cu7rkwWbfY72F8q5YFxzxueV7IJhzSmb19wNuB666CtXrQV+JD4e7sDK77zN
      Wm4PHg16Y7NCM+D6/St2Xse12j3OOHDJ1fIBpn/Ndg==
    EOS
    :braille => <<~EOS,
      eJzVmsFuwyAMhu95atpNW9rD1Ew99LADkD7Aetvz8CSDkG5jSwjGNjDpV9Wm
      ccBfjDEJRh6MfDVSG/1olDByS8E5u5XjLUnbvkkjz5Ob1tlh+nI1Y5rt989+
      5XiSuvB374g3iywDseO7Wz9ncOFVpDPd0tHe6BA3FH31W7WNeB03NFrTzl8E
      7XUxqtDdZqD8BjccWeMjAlpMof1UHxyY8kuu+Y2PdRy0mNNIdXyplKWRD7iL
      cI3jCOj9DweeEW3sEbYQqffkpPxXJyLWp7W/NiPay8b1WIhXBcqL/hLnzETQ
      k5plTUz5zlpRsoaAbpM1C2Uvynz9C3RCPm0qX2uqvMzBOrg+MKKdiMcUgrL9
      xNz1RNHUfBmgRRNrGVS9DG3rVgu01UfldbbKWPthWGMnp2zQAjumULZlKeNZ
      awcaM2UzrlmjlLP73Ocael75UwImon3bZQs+xmIuRfkLGTTokqxRxRyVMgsB
      CtBlHvIRPDCqyZoEtEAX11v9RpXMkoE1eHKiAi0Yi+uSJTMba0LQPKwbpez7
      BpicaEFTs26ZMpA1OWgxjSkM67stirIsiDvpZSMHaEFQh7Qfy4GGzdhiAi1Q
      LxsbquTSdYlvEeED7QV/h1957YdRbBxzgxaA3UBKGnkMKYOI455jULFe2epV
      AHSs+Vn/LCPn+FsG9Ffzh3mDoY1xt8fwOm3cOqZF7uKGyhaiOOLv4IhbN5Xo
      PgGWvkwL
    EOS
    :density => <<~EOS,
      eJxTUMAEj6Z1YBGlAOAwkAu3Oqo5Aa+RGA6gF0CxGNNhFPueoJGDw+cDYjHu
      wCU72IkycuB9PrIsJhybJMc30UaO0CAf1BbTolbjoldViQ0M/iAfmRYTjEIS
      E83Q8PXItBhnVJJRMAwdXw+oxRghS2YZPLR8DQJwj1JQ61Dka8pqOy4AvTj9
      XA==
    EOS
  }

  REFS.keys.each do |type|
    define_method(:"test_#{type}") do
      klass = Termlot::Canvas.const_get(type.to_s.capitalize.to_sym)
      c = klass.new(120, 30)
      c.points!(@x, @sin)
      c.lines!(@x, @cos) if c.respond_to?(:lines!)
      s = StringIO.new
      c.draw(s)
      if ENV["GENERATE"] # Generate new refs instead of actually testing.
        ref = Base64.encode64(Zlib::Deflate.deflate(s.string))
        puts "\r:#{type} => <<~EOS,"
        puts ref.split("\n").map { |v| "  #{v}" }
        puts "EOS"
      else
        ref = Zlib::Inflate.inflate(Base64.decode64(REFS[type]))
        ref = ref.force_encoding(Encoding::UTF_8)
        assert_equal ref, s.string
      end
    end
  end

end
