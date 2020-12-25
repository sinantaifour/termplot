require 'minitest/autorun'
require 'termlot'
require 'base64'
require 'zlib'

class TestInteractive < Minitest::Test

  class Session
    include Termlot::Interactive
  end

  def setup
    begin
      old_verbose, $VERBOSE = $VERBOSE, nil
      # Assume a screen of 150x35.
      TermInfo.instance_eval { def screen_width; 150; end }
      TermInfo.instance_eval { def screen_height; 35; end }
    ensure
      $VERBOSE = old_verbose
    end
  end

  def test_interactive
    s = Session.new
    assert_checkpoint(:cp1) { s.plot([0, 1], [1, 0], 'g') }
    assert_checkpoint(:cp2) { s.width :full }
    assert_checkpoint(:cp3) { s.title "Test" }
    assert_checkpoint(:cp4) { s.plot([0, 1], [0, 0.5], 'r') }
    s.hold
    assert_checkpoint(:cp5) { s.plot([0, 1], [1, 0], 'g') }
    s.reset!
    assert_checkpoint(:cp6) { s.plot([0, 1], [1, 0], 'g') }
  end

  private

  def assert_checkpoint(name, &block)
    res, ref = get_res(&block), get_ref(name)
    if ENV["GENERATE"] && ref != res # Generate new refs instead of testing.
      puts "\r#{self.class}.#{name}"
      puts res
      ref = Base64.encode64(Zlib::Deflate.deflate(res))
      puts ":#{name} => <<~EOS,"
      puts ref.split("\n").map { |v| "  #{v}" }
      puts "EOS"
    else
      assert_equal ref, res
    end
  end

  def get_res(&block)
    io = StringIO.new
    begin
      old_stdout, $stdout = $stdout, io
      yield
    ensure
      $stdout = old_stdout
    end
    io.string
  end

  def get_ref(name)
    if REFS[name]
      tmp = Zlib::Inflate.inflate(Base64.decode64(REFS[name]))
      tmp.force_encoding(Encoding::UTF_8)
    else
      nil
    end
  end

  REFS = {
    :cp1 => <<~EOS,
      eJzl2DEOwiAUBuDdK7D0CKiTZ+EM3IEYB006qGFwrNWTcRKtHUALfZTSlofN
      G/4OHfhCH3kQtqNcyVJJkWmdCaN8Rdp17psXwrYbrqqTka9GfupcH3R+iCar
      SuRR3yDvvO44db7oZavthNjZTJCijwfWuvhqtfmOSi7Uyc52dLA5/lNEbJGc
      YDbk7W0aJ6ecR1dLSmsuHljLu6v9AQ+slcbeSoMH1lpobyXJM0xrloMSg5Od
      bcRBGcCG0CmcbURXw+/klIsxNeXIA2sN6Go/Ey01J1q59D3EdHX7rLPQay6i
      PMatwAtLRlYx
    EOS
    :cp2 => <<~EOS,
      eJztmb0NwjAUhHtWcJMRDFTMkhmyg4UoQKIAlIIyBCbzJBAjwEB+XrCsZ5uL
      rrgUSezzJ18ki3whC11udamgOLUTuSwm4r6Qy+ZG5PNZoauN5feWP3T42vKX
      dn9W7f5kvK4UFKbe8bj56Rc1vU8bENYdcI0FrQOuegXQQpcNTEbFh/BWMl8O
      m1c/X+zRJiw/1BA+67xVoRP5xETN0KBQhXEoSHwIo0YV8uYfIzWEaaEKvcab
      JDVDk8ZW5RjgH1JDSAVbVX8+oGZ8Zvhrf0YBfDyEmngVghoOxV6FoCY8RVSF
      wCdC8VXhxwmnbNyDmpL7lB76WUezkNlrUbPQLutE/Qqo7IPj
    EOS
    :cp3 => <<~EOS,
      eJztmj0SgjAQhXuvkCZHQK28h11qSyo9AONYyIyFMhSWCJ4sJ1GYYYjKz1ND
      QmAzr3g0gex+87YInOtZ6812N2Ni5fkyPsk4ILmpMxOeXzZynz8wsVz4MgkV
      f1F81OBTxd/rfXqofBbU+1vhZRKQBqhXTp5+/oFP1wYFFMcG0EIAtKgbNNU3
      gZYRaPakAsO/wAfbuxUryjL31Sc+wMvhCENYowgzLqv4YB/YihUyJSnCeuzO
      wPEBTkARZrH4ruODndJEhE0Hq2lQA5Thb6yA5BrfZCR80DppnYxjiTDCR2ct
      JxdhhI9BjS/CCJ+ByUyEIYghEUb4uCbzEVY3Lt+uurzclfjEtu9tST/rWjSS
      V03V9EuEvqVcrT4AdjFXTQ==
    EOS
    :cp4 => <<~EOS,
      eJztmb0OgjAUhXdegYUnMBDj4Hu4MTsy6QOgm8bBkA6O+PNkfRIEQtqkFhFv
      aYHTnOGwXe79cm6TBgHJ2Wx3e8+P12HC2YWzFBqbrn4cJs0Ij+UHz1PINfnx
      Mkr4My0HpPp7Lnz+0ngm+Uzjz5I/1V6AUflwsQIxtlVP6KGh4WcydDRkKg2f
      /bdqBSrvnQF0jJOho0H21Dmh+APBfIEOJRZkgdEFkT8Cg+iXgQ4pGVoaqFYJ
      RWAQ9QToTG6VDNW0GaAzEBm2N8hQzRw5MTO8Wzgi19HB3cJZWUYHd4vxyiA6
      WCXTVn90CAKjyypBYLiqNnQMxkMrENabAqlSX6xqZBpimO0XV6iHbuUQvUAe
      qFOnKiyqiiwA/hYYxg==
    EOS
    :cp5 => <<~EOS,
      eJztmjtygzAQQPtcgYYj4KTyPdxRp6RKDoA9LkwmhcOoSMknkyP4QDqJgQRY
      O8he0AehLLPFc4OF9HZXGvB9Ndfm+eX1wQvXQcTZO2cxxTLj6IVB1C7krv7h
      hU+PEc8SwB+AUwEXgL+Gudj3XMbDnDfMs5jCwrj0pOLVH33u3aCR4iAQLUGI
      lt4XDbJItJJEmy+gMP4IfXD3vqkV1bLlh059EH+OLmEY16iEGY9Z9cEN8KZW
      mC5JJUzj6liuD+IJqITNOPlL1wf3lCZKmBtaVWNegfFLcjc/U5h1JzvnDcUs
      i6zCiCpprAvbZ1nDqQS/AU6mMG7eKBvGylX7C3YXZSJgsLsoYa6cAH8j2gBk
      NnBPa+VSNPluG/ozqYWiypVn/6Vyced62MKzQa3IUi0YsozIkCeJ/MtbKxbo
      Om9UnZAtOMroSQsHjZYuzXYabTp1NLccTOpgWo44LUhbCl3JYbCvDO3Nrl7i
      BzW17rO5v0ihmByfzUL6/aIq+thL3QU+GjkDgJGlAA==
    EOS
    :cp6 => <<~EOS,
      eJzl2DEOwiAUBuDdK7D0CKiTZ+EM3IEYB006qGFwrNWTcRKtHUALfZTSlofN
      G/4OHfhCH3kQtqNcyVJJkWmdCaN8Rdp17psXwrYbrqqTka9GfupcH3R+iCar
      SuRR3yDvvO44db7oZavthNjZTJCijwfWuvhqtfmOSi7Uyc52dLA5/lNEbJGc
      YDbk7W0aJ6ecR1dLSmsuHljLu6v9AQ+slcbeSoMH1lpobyXJM0xrloMSg5Od
      bcRBGcCG0CmcbURXw+/klIsxNeXIA2sN6Go/Ey01J1q59D3EdHX7rLPQay6i
      PMatwAtLRlYx
    EOS
  }

end
