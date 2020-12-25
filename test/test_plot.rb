require 'minitest/autorun'
require 'termlot'
require 'base64'
require 'zlib'

class TestPlot < Minitest::Test

  def initialize(name)
    @name = name.to_sym
    super(name)
  end

  def setup
    @x = 0.step(3 * Math::PI, by: 3 * Math::PI / 30).to_a
    @sin = @x.map { |v| Math.sin(v) }
    @cos = @x.map { |v| Math.cos(v) }
    @p = Termlot::Plot.new
    @p.width = 120
    @p.height = 30
    begin
      old_verbose, $VERBOSE = $VERBOSE, nil
      # Assume a screen of 150x35.
      TermInfo.instance_eval { def screen_width; 150; end }
      TermInfo.instance_eval { def screen_height; 35; end }
    ensure
      $VERBOSE = old_verbose
    end
  end

  def test_add_invalid_args_types
    assert_raises(ArgumentError) { @p.add("") }
    assert_raises(ArgumentError) { @p.add("", []) }
    assert_raises(ArgumentError) { @p.add("", [], []) }
    assert_raises(ArgumentError) { @p.add([], [], []) }
    assert_raises(ArgumentError) { @p.add([], [], [], []) }
  end

  def test_add_incompatible_sizes
    assert_raises(ArgumentError) { @p.add([1, 2], [3]) }
    assert_raises(ArgumentError) { @p.add([1, 2], [3, 4, 5]) }    
  end

  def test_add_invalid_opts
    assert_raises(ArgumentError) { @p.add([1, 2], [3, 4], 'j') }
    assert_raises(ArgumentError) { @p.add([1, 2], [3, 4], 'j-') }
    assert_raises(ArgumentError) { @p.add([1, 2], [3, 4], '-cj') }
  end

  def test_add_repeated_style
    assert_raises(ArgumentError) { @p.add([1, 2], [3, 4], '--') }
    assert_raises(ArgumentError) { @p.add([1, 2], [3, 4], '-:') }
    assert_raises(ArgumentError) { @p.add([1, 2], [3, 4], 'c-:') }
  end

  def test_add_repeated_color
    assert_raises(ArgumentError) { @p.add([1, 2], [3, 4], 'cc') }
    assert_raises(ArgumentError) { @p.add([1, 2], [3, 4], 'cm') }
    assert_raises(ArgumentError) { @p.add([1, 2], [3, 4], 'cm-') }
  end

  def test_add_first_form
    @p.add(@sin)
    assert_plot
  end

  def test_add_second_form
    @p.add(@sin, 'c:')
    assert_plot
  end

  def test_add_third_form
    @p.add(@x, @sin)
    assert_plot
  end

  def test_add_fourth_form
    @p.add(@x, @sin, 'm*')
    assert_plot
  end

  def test_add_multiple
    @p.add(@x, @sin, 'c')
    @p.add(@cos, 'm:')
    assert_plot
  end

  def test_limits_narrower_than_data
    @p.add(@x, @sin)
    @p.add(@x, @cos)
    @p.xlimits = [Math::PI, 2 * Math::PI]
    @p.ylimits = [-0.5, 0.5]
    assert_plot
  end

  def test_lines
    @p.add(@x, @sin)
    @p.xline(0)
    @p.yline(Math::PI * 2)
    assert_plot
  end

  def test_decorations
    @p.add(@x, @sin)
    @p.add(@x, @cos)
    @p.legend = [nil, "cos(x)"] # Incomplete legend
    @p.title = "Trig"
    @p.xlabel = "x"
    assert_plot
  end

  def test_size_full
    @p.width = :full
    @p.height = :full
    @p.add(@x, @sin)
    assert_plot
  end

  def test_size_auto
    @p.width = :auto
    @p.height = :auto
    @p.add(@x, @sin)
    assert_plot
  end

  private

  def assert_plot
    res, ref = get_res, get_ref
    if ENV["GENERATE"] && ref != res # Generate new refs instead of testing.
      puts "\r#{self.class}.#{@name}"
      puts res
      ref = Base64.encode64(Zlib::Deflate.deflate(res))
      puts ":#{@name} => <<~EOS,"
      puts ref.split("\n").map { |v| "  #{v}" }
      puts "EOS"
    else
      assert_equal ref, res
    end
  end

  def get_res
    io = StringIO.new
    begin
      old_stdout, $stdout = $stdout, io
      @p.draw
    ensure
      $stdout = old_stdout
    end
    io.string
  end

  def get_ref
    if REFS[@name]
      tmp = Zlib::Inflate.inflate(Base64.decode64(REFS[@name]))
      tmp.force_encoding(Encoding::UTF_8)
    else
      nil
    end
  end

  REFS = {
    :test_add_first_form => <<~EOS,
      eJzt2ktugzAQANB9rsAmF2hFlFXPwhlyB/pRP1FVNRWLqOoCSA7Q7noen6QF
      jDDFwPg3HqeJvJhIkIznYWMSR8lVvGHZM8vSc3PQXqMk3iyipso31RuWp/AW
      JevVhhV5dWIT50chfhPirRA/jRxTdnF5VE6GcuOdSrsOKhdtN3KMcG55pyHY
      0dfx6jKu4qXORSHp2Xbq9GHPNHpArQ2p80yIrx0WRCRb/r7UDFX1phMXr8si
      DU/VhNEKqQEmr/qHTtWH+RZBjUmJ24t+HcoDpNoaULbS7KHtw5tIJZPOrXEd
      vqBTjzodr66lfHtZPwp6JXU9Xl2tKXGmDnvQ1KNI58Lt74cD5grPXFp3BEMr
      FSinSvStrCspWYGhEJQoWzlSglvBoNCUaFrx4n077/KEFQAKWYlJVxv3/tF4
      /T5tridM9Obo7K7fw9XjOSC6zepN0vlyG9MrPOnhzzuSOgye0wB0mFy9ZPc+
      h5xfrl4ddrNQmEmNEWH+aEUBp82EFItHGTomJFm8yEjuvQ9+K0CQhY3fHZFM
      0G+wgbCgyRA0oc2CIEPThDyLUxmyJiGwOJKhbBIIC5M+chqszez+x/qPWToZ
      4/9q8X/vPGmWHs5BZ0KTDJJ3st0Mi4XJho242XNuk8ZABrwv7exjqATedSpR
      mtzV6r2zcMM6vuAbY1vMzPfW7VNt9aJnsazLHLdDCPFVf/G6sf4BzqWexw==
    EOS
    :test_add_second_form => <<~EOS,
      eJztmj8OgjAUh3ev0IULaGpITDwLZ+AO1Tg4ODAwOKJH60nUUhRTI/QJ/eeP
      fAM2KW2/Zx/aPFZseSnrk6wFmIGKFbxcsNby/vFBNmI8rMg3pbyIt45tY7N7
      NbYtV2H9/MAxl6/XfvwghLD8flzU/XrFH/cZPWKA4D67X3bK9fegsYsPrVc4
      6PkfSKse1+u3sAACUB6B8mlTRyyJiJZwyE/DTnAOlEN5+oxWrlPUnKFwMARl
      PtX8SzaGwE5wDpRDefp8VT7tj1rLefnJ/R7/b/RzP3aCc6AcytMnVOVu8q7H
      F1oMQUgYKIfy9IlB+bSnKKGdEUUShMSAcigfnC8lUTg48v2nICRAzMrNerhn
      42DpWJgYdWlLXZjWhaX2XdeYKmdlOVOaebcZHF5q4LyN9Q1B2k3k
    EOS
    :test_add_third_form => <<~EOS,
      eJzt2k1ugkAUAOC9V2DjBWqwGiln8Qzegf6kP6ZpasOCNF0AeoB21/PMSVpx
      DEMZYH7fvLGaWTwT0Dfvg2GACZZxuCLpM0mTc7PQXoNluBoFhyrf7L+QPBFv
      wXI2XZEi3+94iPMdE78x8ZqJnzq2Keu43Ekng7nRTiV1B6WLtunYhtm3vFMQ
      rOmreDoJ9/FY5aDg9Gzdt3u7Zwo9wNba1HnKxNcWC8KSjX8/coayev2Js8dl
      kfinqsNohFQDk1b9Q6Xq7XwLr85JjtuLeh3KrUi1FaBMpdlAy/wbSDmDzq12
      Hb5Ehx55OlpdQ/k2sn5k9ErserS6SkPiQB0yoaFHks6G298fFxgrHHMpXRE0
      rWSgrCrhtzKuJGUlDAWghNnKkpK4lRgUmBJOK1q8b+td7rESgAJWItzZxr17
      NFq/T5PzCR29ITqz83d/9WgOgG6Der10rty69ApHevDjDqcOrfs0ATpIrkay
      mctTzi1Xow6bQSjIpLqIIB9aYcA5ZoKKxaEMHhOULE5kONfeB7cVQMhCuq+O
      QCbgF1hPWMBkEJrgZgGQwWmCnsWqDFoTH1gsyWA28YSFcG85NeZmZt+x/mOW
      Wkb7XS38886TZmngbFUGNM5J8o62m36xEN5pwy72HFqk0ZIRXpd29tFUEl51
      ylHqXdXqvLPihlV8QRfGHjFT10u3T7VVk57RuCpzSBcj2/1UfxVP5pfzKIri
      RRgt4tlVlcUP9p6gGA==
    EOS
    :test_add_fourth_form => <<~EOS,
      eJztmjEOgjAUhnev0IULSKogyFk4A3dA4+DgwMDgiB6NkyilKgYj8ITS1p98
      AzYpbb9nH9o8Fkc8KfNTmadgAjIW82TBasv76kNZpP1hsbdJykv61rFuLHav
      xrrlmg5+vua0ly/XfvwghLD8ZlzE/crl1b1DjxgguHfu1zDl8ntQDIsPrZc+
      yPkfSKvu1+u3sAACUG6A8nFThymJiJZwyE/DTlAOlEO5/fRWLlPUlKFQMARl
      Ptn0S24NgZ2gHCiHcvv5qnzcH7UD5zVP7p/x/0Yz92MnKAfKodx+dFWuJu/O
      +EIzIQgWA+VQbj8mKB/3FEW3MyJDgmAZUA7lnfOlJAoFR77/FAQLMFl5ux7u
      2dhZOqYnrbq0pSxMe4Qln7uu0VbOwrIjNHNZDDjtJYaKXH/th2EYBTwMIm8r
      ZnEDQYlPFg==
    EOS
    :test_add_multiple => <<~EOS,
      eJztmrFOwzAQhve+Qpa+ACioKhLP0mfIO6SAgAGhImVg6JCmAytseR4/CU19
      qHZzts+O7VCc6ga3TWzn/+y7s+NsdZcXrHplVTlZANtkq7yYZVzl++5Ltlos
      C1avuzKrS278x30JF9wWbFedyvW78PujdKOD8Xoaoa16K5Qboa1yaFsD+7mU
      +wDSvSDSNRG7KtM8lG+u8648lzj3Jd9tpUfpxG69iQ2VvJ030ezHZDiuiTjm
      hw/OB3T6EubAujfm6tO/zae7okCpRTrAhzVc8BQVGjyjpWdxuyskQ3GCSdL6
      mGZw+zPeRNMmOs0IfJCA01NRIzAdDgph9Nn1R4wOSjGUz/4VHaMtKDFMIU0E
      DlluPTfUFsANkomp5gwM/Q/37JE4dfujIykzgQJthByiflDq5OYGKfIPcbAX
      bUQ+BPFsx7cqL0FqnrDgWFSxQhRP4+LAPfeWZDgoLYRALg56uIkS9Ew6+EVn
      GtO2Hkm/VFOOjoRzPy0o+oCGK78tQZFrTi0oEbDs6FjIHokudprpHAGLKv+1
      UhpdMyBZIhkUD4CDnz7Gho6y3WEBkLZPZBSSkoalOTdiQqDHDW1ymKZ5gmC1
      bZBmFI9Cg6guvAYL7JTGChGG/thv5fnDok+K6blcguYPAvENz+SmAtMwamy7
      gk/WvNJQ+SiVd/K7JeV36ymk5Bb99MrHmGtNjisKDaZeBk6LvugQNEGduPpz
      82NxNuRDcjD4MX+gGDZhppyXppt3COKLDukc54B0K1MfVzUezbx0M5437Z0E
      vYKjoL8wq7HPH/9XOyZMs/lR5hyO38b8HBtecNY/1yxPAg==
    EOS
    :test_limits_narrower_than_data => <<~EOS,
      eJztmltqhDAUht9nC764gYoxjZe1uAb3YC+UMpTSgpSh9EFtF9BuKSupl8xM
      HHXqoJKTnEoeIng75+P/cxJjxZGb8OyJZ+l/W6G9WLGbbKw2y7f1Cc9Ts5sV
      Uy/hxXcdbNvPbxQELue86bsOq/s2Fhpt7stU4vCsLGQ553Z1oIAglJApVgJW
      CANGtFUfKRoIoPwHJQRBIJcI3AEKEAEEILUQVggDFvQBMS5zIQgBQLUgBBCg
      FaHIIECugnBA0MiCDIWglwVNhlCFQippl3qEwgfnA+C9SP54cpTxeW201+Y/
      R0pFCj1Q+FOF82QOQxyRquwJJibu2EmKugcat45j+SmlXKK0lSlMGW3EfY/S
      M0q4GtN04JdTfbAD0rODS+oD8YBXiRUYjelcHIz6Xveyiwq5vsbKB8X5MMD3
      ihHfmwGqg+tTvQ2aYHfZqN3NBsVh2KBRdveXC8yYwyq0wYFpEoD/hhdR6tjd
      BBeYt9igtiw0SlGTf08ssTzU98Pya5XMIVTUoqBGcS06fOEU0gqg+PqWiFlR
      6xDrcFtCYwOzpjddpdVh9T4nvSebMq/Ersw9ukz1hl1TW7O+urGbNFOHXBMW
      eT6jLIyCiO4FtOTRvMl3vJCSkFE3IEHEQr/5il/MQxRi
    EOS
    :test_lines => <<~EOS,
      eJzt2k1OwkAUAOA9V+iGC0iKECpn4Qzcof7EH2KMmi6IcdEORHdGFyYkepqe
      RClDGOy08978S4bM4pFQ+uZ97TBDJ5qM42mZ3ZZZGpqBdh9N4mkn2lT5bP2m
      zFN4iyaD/rQs8vWBmzhfMvEjE8+Y+KbhM2QXkyU6GduNrLCFIumug+iiPTR8
      hjmWXEgI7uiruN+L13FX5qLg9GzWdni9ZxI98A28Tp1nTHxqsCAsWff3hTPE
      6rUnzl6XReqfqghThVELqQImrfqzTNXr+Ra+3ZOtdBy3O/k6kAWk2hJQutLc
      Q5v7OpA2i3EGnXPlOnxAhx48Ha2upnz3sr5m9Ig3eg10tLpSQ6KgDnPQ0IOk
      M+H298sBY4UrMZVfBEUrDJRRJe+salDalVBWYCgLSn5Z7UMZUoJbwaCsKXlk
      xUDR4q2Md7nFCgBlWankzjYu3aFtxWj93nXOJ1T0RHR65+//Uq+iozlYdBPq
      tdK5cmvSK5zokZX9cYdTh9o6DUCXv23SXFpr9LzfzOXz4iYHwuSQvzqqw6cQ
      yvbVjFw5Gjo7ey+RL1d18IrFoUzj+IZ5anO4LE5kOL+9V9szBpaaDPhfTM0m
      7HwosDiQEc9RA4ttGdC6IbBYlYGu5QKLPRnE+jqwiGQ0Pc/FPWMNLAAZ5We1
      6P87AwsYZyEzoHFukifAsYEFI8PcNuxmT9EmjZoMeF9a8FFUAu865Si17mpF
      JObasIqP6MbYLWbmeuv2obZq0tPpVmWO6WZks6/qVOPe8HiYJMl4FCej8eCk
      yuIHQyW19A==
    EOS
    :test_decorations => <<~EOS,
      eJztmrlOw0AQhntewY1LKEAOIELegy4lBaKIkKChNIcCBBQuFxQUtpMHIKLh
      efwkxNYmHtu7zh6zRxCRi4kw2X//b73HeHxf/HN0fnqy4fV7wSCLnrIo/L/U
      rhevHwwWhl7nX7z+3u4gix9A/AbitIzTaR5ncdhyze/sDLIkJv81j+MIxG8g
      fgDxK+OeaRmnt6tbN3YRQ0Jg1JRh4Ogvm1wdSPO4sxPkse8XvTk+u9i83GoM
      uaaTS201N5KQoofS/VGb7Gb3rY8lyviJQHzFlOe4XZByPn0zsVd6cw+G/7C8
      U1R4eycSG8xJp2Jhzi67JAiZ3oMUtPkFtPNZUu/BPRisQ6OcyYMHCd8Id8Ed
      c6TYdsBUljf4CcyYrZidhHuQGsJLNH8JP67OmiM+Ode1jyvTTm0hkptgyS9/
      gxEv7oQM2E95te54IoU0Gdf/SoR/IAmfmYCpgtEdK0QAkp9h9Hi9GKLMrk55
      wk2yXfJ6wTSD0bAnfCR5JFeEqy32yxbTCRpAk/QMWMHBjV8p1JvOlBYZFGLm
      WWlyYBUlxWOPrp21GkNKHkDwlFih56o5rWzVz7M6huM6YmxagTWXcgCUm3ZK
      vVLeo6R5vGbS9VnBMJhxkxoFip5kMtkax0FREDVOaPwyJhiIMDzRR4mVFRYm
      9lFaxbmtprC6s/w44Zqjh5tddLgPGC40LHO0cbOITl/S0joxnbisEHOZlbon
      mnGV6rASPT/MRM9asFL0RD8ufGK01Bxl4VKBFpuApmKOEW4Z+vQI3n1NbnE2
      GQlkhbTJQPfEFC66OvF34l6zbOFR9XCtntIw5olBXBWB70CgQFEVM/XbPG4v
      y8H43/VQ1jHZt6rGXDIOsCLwlQsjZcmCRaK0Ki1pnhSGkZ1HUdo3S0hZAmFd
      JeQ2ATwr8yerAHjVkkVh3lqdS3JbIf0eZiWw7SGg5natzHib1Bkvxkhku67+
      D1zFBnXDLxwNFmXcop9LrruKNno7+7v73W63dxB0D3p7h0Xzv9XTmEU=
    EOS
    :test_size_auto => <<~EOS,
      eJzdmEtOwzAQhve9Qja5AJVLq4acJWfIHVKoECCEoIoqFizy6AHgSj4JxDF0
      HI8fSew0IvLirxS3/3z2zNgNkpikNH+mefa/xmuQkHQRtOHdNh9okaEjSNar
      lFZZ806riyPQT0A/Av0G9OGsq73ut7yO1kBZ4MaUgRyGBALBMr1akkaHBuSI
      R+hrp5sFkVfVdJiRDZJ3WWomCrYVUCG08OdRUkS8fFiRkL3U/neqarVt3dbn
      iWUmo7BhxoH1tyAYeQBLeO8RG4/105wSlotc7js0jMwQYHe9I0aw+UlYHmU+
      EJjg9h3HZmLmBFjHS1U7pjVyY+lp/VU1LSq3nGRaqjoxCphdcTXTkgqIBarB
      K4Rb+HIGCWlCL872q3UrnAkSrzCm4uEKiW8YE/Kgpr5gC2Po0WN+POiI85DD
      BjQnHgIV0IZqde4gh2LXOXJpHgIVeFE+dQ8NkJb8jqA95I4GFdNX/Fb7yyy/
      9L8azgerbYuQxUf4Fb73w2bHy831JoqieEuibby+YV/8Df3lKDM=
    EOS
    :test_size_full => <<~EOS,
      eJztm01uwjAQhfdcIRsuUBQKIs1ZOAN3oD+qSltVpWLRRReQcIDSI/kkbRKD
      xsRO4sSOZ1yQF65E7XnzPk9MEgfzOFywzSvbLC+NVHsP5uFiEBT+3WV/sO2y
      XQvmk/GCpctskKK/3YP+BvQ/QP8Z9FeK7yTyMYu5WgfsTTOQ+bXiO2Cc5MFY
      5iFveX88CrP+sCuJRXS7rULlbc2w5WQUop077IqpZKngaFWfFoPJhFQM/z7t
      MVEBojuCUKpAedr9m5JUA0jdUrOaVRO8SEh5ae8tH+EJLIZHz0kxC4gkmaCy
      7HQqSzc6JLK+zDjJR0v9ryY8hx2qcFUCWy2yDlBYUnMu69PnXQnn/dtMgVDm
      8KC3ttpCYVuNoAngvv3xsHZwOW9W5EjWVl3JaAVFP0Scy9LEHXnjQgxdbatn
      SdJqN3UR6Nl/OGnrfRKqJtl22akI8nnVOGiy0A/E5RlhiaNIgSv/hRzW1dPG
      LNj7EaGtiey20va2WyOHlVw0g8It3xJNBG9VSIi4d5pDNRcNoMBDhKCJFBd4
      iBByqOCiDgpsRAiaiHCBjQghhzIuKqHASYSgCT0XOIkQcljiogEUeEAQpCDG
      ATMIQg7XtQg4j1QeOErz8dt+jJOQ4Qyr51TcZvQMZ/g8J+Q2I2k4w+Q5LbcZ
      VcNPmdZ6bGYpBkJuM8KGM+k6T/q+A9/zAzQTYdM1HCa++nmo2bnImcx88PmU
      /t5eQONTGHopsPdceWD4yYTkYCVsDI85O0vww2d2fvfI/IsAfExSGzKZCm8M
      Z9Z+nEkWNs0yLoryyXlolKlLOoZXLowmxz/DmWzNdztLk/1X6tdSB+q8RABa
      pwKhyRlOySWd8oIXpXnsPFCZm6Z5sBoe9RXM3yvGKR3idi7cXALPjipf8bPK
      R142ro/wX5puy29bD4a5gSE/ee7ykwcSj6bX0yiK4lkYzeLJTR7jL4uoeO0=
    EOS
  }

end
