require 'minitest/autorun'
require 'termlot'
require 'base64'
require 'zlib'

class TestCanvas < Minitest::Test

  HEIGHT = 30

  REFS = {
    :test_braille => <<~EOS,
      eJzVmktuwjAQhve5Apeo2uNwBu5gWtQGFlVTdcGiC9twgLLjPD5JnUcrguww
      nodjpF8IrCQ234zH44md3jr96bR1duOMcvqGFsunx5W/cLF8WF016nWg8erK
      smSVM9rpr46A59B0X47uAOVggxzqQKNFcajGv+vWTgAj3Yc8/Rb9On5N0zpl
      lsFUodba2RFutEcXNBVuQ48aAO3IqTcGjdFr70wmjxDg/p1+40F0uk+AVp37
      v84PLpnyO/b2kxzradBqCDWz44NS1k6/0B4iNY+joIel+Xkcg+wbuqfwA0Vl
      fsCBOzLaj6vR4s0QeSDMGGN53z9kIpide+T/MsdVIOhOxbJmpvzH2nCyTgFd
      JmsRyr04Y/oIdFqoLTOmW/bYzW+GWEeJXt+Ked4RuPtPvEOAxZM7IkCrIvZE
      pLw7ta/TXKC9zjOXXwxiD0lhTV3A0KAVcU7xlFwy4yZDv6y0VMGqbGYzELjT
      VsuavIYT8giK1/d9500cBZNCiPAbIjLonKwJKSCfkMkCB+g8BUWG4tScrFlA
      K2ICPsTQDSCGEvLroRctVEFLXre40CvBlDxnoi3GmhG0DOtCKfdjS1iueEFz
      sy6ZciJrdtCqm1N41oEITsAtHKljAr38lECvGHKV8r17pOamtwmBVqSXnwVl
      e3Dtp4+1yIHulX6mYOb9IUVT81gatEo4wWS007tLyrjqDVv1g4t+5MBaBvRT
      3Q+6sxiN+b95QP93vx1OUHqvbw9RHrvDZjtI9ACeIS3MwSdQNK0xPAGjql+n
      jJUQ
    EOS
    :test_dot => <<~EOS,
      eJytlzsSgzAMRHtfgcadO08m6bgKZ+D+bQgZBn9W0kqJCiaApCevBMSl1Frz
      bcv2eu512R77dVLak+uO0w5GKX8gpfNY6ng9YLVcv5h0yeFLYrl0F/h07VRq
      TbzBFhIDpC44alMldrob/AMZcA9bOXAnCIrxtMSMR4ucAam7ry9EqgRqkoUS
      MDhC1kIU8gD2k/UAmXyCYYujs0DH2bMwquLUBT8XTLoZ7CITvoILADveC1SN
      2AmAMVn9epIiiSNy5k3qlJFyoOdfn15UFFKFLMEePi0dBjP68lxIFsA22cNF
      ZAlsDEtTAHCk/upNcWIpeuN9CiCyCFbJfu5ElsEaOfZhZsF258MdhwC1FKxC
      RPmZrIKhCiHh51gDnNdx0Z9YSeDIrupW1Spl6EBc+DGdDW4l+0X4Ac2A83ev
      eRyba+IOM7B36kk5vQEQ3haK
    EOS
    :test_ascii => <<~EOS,
      eJytl0uOwjAMhve5Apsqm5EqSx0xt6DcgFHaC7Dg/puhRX0k+f1IMl5AIba/
      v3m4tQ9hou6wy+Pn+qTL4/sp/ig0mkLwPoxTI8ktH/NI6f8VioZ5u/SGdO7z
      9UGz+mqm6CRkF1MIcNtF3zQx1Kf//CoRO7iJnHPVfAe4o2oyjpTJO/i8EoTm
      qWQvICVR/Kw5xOJW0xbPrEQbScE1ZCm7MJaAy/eCHMGPruB1Be7xEsMQ5Jja
      y7TEb7upji4dRiG8ofMYG3dGMnBZXbjrLl9WcHezcweLE97UAIw9xXJgEoAT
      H3mdiJhtiMG6C0VRaFaMZcE4FYsBqRhsIZeUDuDLgPWsZSWLsiPCgO11KE9p
      fHZlR5uTohVZtdxoZBYMb66em5F5sFD4arhpPgGMydHrCiiiRW+u0eNEksKs
      fN0MLHa+NxHc0fif3Igsg0G1qX9FjaM1cNLJUC/1ElXtHG3ToEo5i6G2viRK
      YgC/0X1YO05TY9vS13bkQyD3B4jTHgs=
    EOS
    :test_enumerator_encapsulation => <<~EOS,
      eJztmkEKgzAQRfdeoZco9jg9g3dopYsue4TUo+UkLZiNMi1miOPk58MDIWg0
      z/EHBmO4xRxO10s/xPf3eB5Wg+EuDK7OhGFe3SR6eAqDk8pDd/g6G2GTaHVF
      Y3wK6kLOvZBVbwRFUzQWP0WnrXksFsHFJ9yV9LSv0sv/OyGr3giKpmgsFqLN
      otZnphfP7twbseqNoGiKxuIw0RgtF92q505LJ3Zl4RF7sMYwXigaC4puSXTK
      0Me+GZruErzsTy7UtwBFUzQW7kSXTXBvSe1aPSoUTdFYuBat69546H5Urx6J
      akRv/Ie0lgJfvIMPV7CIug==
    EOS
  }

  def initialize(name)
    @name = name.to_sym
    super(name)
  end

  def setup
    x = 0.step(3 * Math::PI, by: 3 * Math::PI / 30).to_a
    # Keep everything in the range of 0 to 1.
    @sin = x.map { |v| (Math.sin(v) + 1) / 2 }
    @cos = x.map { |v| (Math.cos(v) + 1) / 2 }
    @x = x.map { |v| v / (3 * Math::PI) }
  end

  def assert_canvas(canvas_or_res, name = nil)
    name ||= @name
    res = if canvas_or_res.is_a?(String)
      canvas_or_res
    else
      canvas_or_res.drawer.to_a.join("\n") + "\n"
    end
    ref = if REFS[name]
      tmp = Zlib::Inflate.inflate(Base64.decode64(REFS[name]))
      tmp.force_encoding(Encoding::UTF_8)
    else
      nil
    end
    if ENV["GENERATE"] && ref != res # Generate new refs instead of testing.
      puts "\r#{self.class}.#{name}"
      puts res
      ref = Base64.encode64(Zlib::Deflate.deflate(res))
      puts ":#{name} => <<~EOS,"
      puts ref.split("\n").map { |v| "  #{v}" }
      puts "EOS"
    elsif !ENV["GENERATE"]
      assert_equal ref, res
    end
  end

  [:braille, :dot, :ascii].each do |type|
    define_method(:"test_#{type}") do
      klass = Termlot::Canvas.const_get(type.to_s.capitalize.to_sym)
      c = klass.new(120, HEIGHT)
      c.points!(@x, @sin, :green).lines!(@x, @cos)
      assert_canvas(c)
    end
  end

  def test_enumerator_encapsulation
    c = Termlot::Canvas::Braille.new(120, HEIGHT)
    c.points!(@x, @sin, :green)
    d1 = c.drawer
    res1 = 5.times.map { d1.next }
    c.lines!(@x, @cos)
    d2 = c.drawer
    res2 = d2.to_a
    res1 += (HEIGHT - 5).times.map { d1.next }
    assert_canvas(res1.join("\n") + "\n")
    assert_canvas(res2.join("\n") + "\n", :test_braille)
  end

end
