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
      eJydl0GOwyAMRfecAmUzErKUeyQ9QkRyhVl35u5N0hKI+dimllpVH+yHKXbI
      EONKPts6xmFgmtFojYfvvCraae742uaEoSENZM2KHbf0cyBBK8EJk7Hd6AJx
      YZDGwd4H8iOPFsxkClxZoAbAfnrW8azkmuH9/0OMd4EpEKAgzTaLCK06awlM
      2/5Z6plIs3H3QwL0S/uAP3uFKCq5vVPSHrqSCynabkvRhTF344pR+rnSqPP3
      M9lL/gVjpTaB8VM7wI9KZdauKlRHdw35Tm8w6xtyFTADtcrX8gPclgNc9asJ
      zETevloznopLxYE/EM5EOSMu0GCpOBRwAxrIeQS+aC0wEwc0YyMx5nsYWCEG
      Q/IfC4YKD0dDcxtgvZz7Cp6q498Aq3HrSLiZJKsKsgWG5Nxc9MahkZtgmFPy
      7udW5DZYaGHfcHk8AdwkE6hpncseAxK4ccJgvqYrUpmJCPY0A83YwxSyDAad
      ZM/N1MOw5Z3RwOwa/r46Mu32GqCRU9IquMTkG2uh9WCLIAbwjgnxfPkiplEM
      vdgTvb8UknsB2tPiOw==
    EOS
    :braille => <<~EOS,
      eJzNmkFuwyAQRfc5NVWrNsmikqsuUqmqwM6iy2aX83CSGmxHWDEwMx/sSLNI
      pHwzfszAd7DVB6s/rG5t+2KNsjoZrbJd/+HsJUfL0m4Vfc5GW/3pU+0TbvyH
      s7+Rmtp57Obf945aDJkb8jl+raR2K8SO0VP8N40rkeJaAugJWTtH5hAfaVds
      HqK685jiyBAtE/QQJ2v8JcwfedRgeMOY7QqUv/nCztWH074LtVLQypV29yO9
      4ROrs4pSFpAatBdriI17H5c06zjoMWO/jAjH7rWv61LWyV0kGWbQnoBeTGkj
      oF3Gwdy2b8DNA1oeKcESd9OGi3IV1kugF+qir81OOjaiXYfydSlncS9+LbK+
      A53oPoRX1bqGKMe0e2vErBfqeg46u8ZBdV1nva5COcpLzDoA7XY/Qt3Ja7MC
      6xagTNIirK+hDwlAG6IrKtxTAGVFqoxlrSb7k4xvI2on0Ibl8Gt5ICZlsV9m
      zlDvr+V5dgHohW03G9ci8ywPXmXAMwQZgc6Dlm8mAK8WYy2mDM0QZAR28s0E
      Zy0nJbYZwAxpyKSm/+ugjI32FJNU2QcTbsiNEwwaZc3alOpZZnoIN/MSoCGD
      TNYifxgh2kKsi4BW1c31SpaZHuzNqRRoGi+ZFrXMUm1R1gVBg6wjeT8o5eH6
      jM2pLOjSrB+ZMpN1cdADL4T1pIUo6wrrcizyB4aVQCvMh/jDRpSy+OhPFvnD
      6EqgFXTY2P7Kn8GMXrGWw8gcRtcDPQSpreakpieLlZ8bC0Sqj2uDVow3eoz2
      LR+SIluoUbsV4oB15HWtFUCnhh8jtSLntI+COJPzOqBvwx/GlwT7Gh9flvy8
      q2KC1sE9Ty8ebo41kXPjiPepGrX7BwL3WAE=
    EOS
    :density => <<~EOS,
      eJytl1EOwjAMQ/9zih1333xwwJ0EaVJX2sSJHUAIQeK4j6zbsuv9uu73sb6u
      EQ+z5Cs3KZewITq/02uBz6tswS8mPxGf9P7V5SS0OMDY28ydz+e2gEQTRkpb
      +06Ag6Q0B2h58wUINIGkwcW1bXl4aA5UStnaFmr3Iy+sbG0PNDmqsiJvTtTi
      qItyhXlJdpDbFIWtBSZ6P6iKTBRhxAUJBsmdyAxfBGkOWo6FFuagXgEEPQ12
      yA3yhzWRGOzr2NiCGBJLreZtFQRp0/G+AOH304/3RQiMvbgTGhA1Re+eA8fB
      BkP37usUCUJxYqgXVqjJEOBVZQyVTQZnnEKo8xs7o666HEGeZ5VZeRcXKPEN
      7oziPMKmLhH8H7zwc4/UDF9Swwz9CrBNcjPi0xrWHHiUknDJEe88FS8Wh30A
      AOqdGg==
    EOS
    :dot => <<~EOS,
      eJydl0sSwzAIQ/ecIjvvfIDc/2B12jT+CSHiRSbVgF6NDdOWUms9+mqfSlk0
      caFU186+z/LotfzfShaNUn07m/Qel0ajVGZngzzHtXW+xDp2E9m6DDDqnjfG
      lYo0BD4RRSMDRqsW34j1QFhaVIedgTW6kxt8f2fPgnPRfstEAXY2cl+RWQoh
      28R9QeYJPtnW5CQ5CnfJtiWnyOg+z5pnZ3typp9BrGB3aRYMGE6WqoODLBgw
      lCyeCiyhgUNSybCBgR0UDWi885+FB6Vqh8FKEeMLTckOOCZnuIjsgSNyFRqJ
      2rlgfsFy+0VkF0zJee5G9sH4aldkonDXJAJ2h2f2fKEdBeNq6/3LoigYD0Bl
      uMR2AXjHnLumlPlevYYReKl3Bb+lEtwhNwaPBXreeEcraAV8/P52teeqzZJM
      bqmHfQDHktUF
    EOS
  }

  REFS.keys.each do |type|
    define_method(:"test_#{type}") do
      klass = Termlot::Canvas.const_get(type.to_s.capitalize.to_sym)
      c = klass.new(120, 30)
      c.lines!(@x, @sin).lines!(@x, @cos)
      s = StringIO.new
      c.draw(s)
      if ENV["GENERATE"] # Generate new refs instead of actually testing.
        ref = Base64.encode64(Zlib::Deflate.deflate(s.string))
        puts "\r:#{type} => <<~EOS"
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
