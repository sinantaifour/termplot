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
      eJydl0uuwyAMReesAmVSCVnKPpIuoSLZQsevb+/NRwSCr42ppVbVDfhgYrsw
      xLiQz7aMcRgqzWi0xH3uvDS0w9z+tc4JQ0N6kDUrdlzTz4EUrQQnTMZ2owvE
      hUFaDfY+kB9rb8FMplArL6gBsJ/+uD8rmTO8/3+q/i4wBQIUpNlGEaFVZy2B
      ad0+Lz4SaRbuuGkr0C/N3eYicjNmeae0PTzBb2r5+IUrPHtmcM6NfrI+YxLf
      s/P3nOwlvxvjxQzbwbe8l9eIDNXRXUNzpxNc9Q29Cnq5MGF3zfF+NYGRDwxm
      c9FQTHbgBQprtHGBBtPAoU1cgQZiNsXrhcbkuOaNMRvjPTBcwmBI/lTOgLcP
      l6SxArhdzn0FT+yvSgA3/XJPeqNhBSmBoec821LAOlkEq42kn8v8yWCF/Au3
      TlgFLJLh+21yN3LpTwMLGQbjNR2RykhUsKcZaKiHGQ+F6LAnGOskW2ymHoYt
      70wLXB3Dz6Njpd2uAS1yCroJLjH5xFpoPdjCiQG8YUI8Ll9UaRRDL/ZA75dC
      9wUJpeJW
    EOS
    :braille => <<~EOS,
      eJzNms1u2zAQhO9+arVJGyeHoG57MIoiICkj6LFGevDz8EnKH6uQIpHizpBW
      gYVhAx6R+kTuDkVa9WjVV6uMNfdWd1atRe8+T0HyZKXaTcJ0Viurvoeuug4f
      wpdTuJGW2mnspr/3nloKmW/yKX2tvTWft8e60Oe79B8Ofogktb+t+gBq10AP
      l3iH23f3R9kVZ9pNwo1EPwwzwyKNTKb9Voh7EXSMo9X3odWf8ls9eO2WlJ/l
      wt6PD6OKEc+0KGjXqssGQI+H5ySZWdVCq2yuyGvPVj+gTZ/zrNOg/bi4C5n3
      I9o2o4XCfMlm1TzlqD0SeS+nTYCezCDH65VgDWulpP4QlMdaZi4mc+YSaE95
      NvtMjyNgtKWk8g4hr50XIcZBHRdZz0AvUmZ5NXZ+FOWUdpkXzHoKOkP5+ge4
      VjRj3YRyfdYj0L76rXJkeDVgbdpR5llfxrVxAC3wnnurK+cvlLLCnZxAu+Lb
      CrUD6IWC0IjXpc66EVyV/NNKcqA5E/3sR6D1hXlWt9UOoRnKci1luh4CaLiY
      GIKXWV+zZikDbwVILVucdngx8cGwRuejJwUXQPiNQuwzbLry7zqK2r7tQgbJ
      cuMnxN0sMa5p0OqG5rqhZS4P0AjUAE3mr0KzSJm5WpRjIMapCuiu+oJ1RqqT
      GbJaTygZ4uJUC3RL1pRlbkE5XllWzCuCJlknxgi7MOFsxsr1BcW8Lug0L0z7
      P1MWsq4OuuM2DEdaT+oFvX8Fbf1h8VYytlqA7oKXgFn/Cpuk7ssnlDKhBUNz
      m7NUEBtC5oJvCmvVqvqtBLw5WyGcvzZyUtHzQt682qoEi5wXaAo6RvGJHq3C
      yZUxqV6i5VfYfOyvB+S2AF2Ae6V25Q9u5bXb4Z5mkpuBjvF4PSTowF0PS8bD
      VyXzfaT1cE/DwcPNsWZwhwNy4VDk7i+Fjlgw
    EOS
    :density => <<~EOS,
      eJytl1EOwkAIRP85hcf1248ecE+iMWndLjMwsDaNsTDAc1thO47X+J6P+zFO
      O/SKR5wkLWGzyIeBqw4bSaOVsVm8fnW+Eho2KOlt8l2fS4ESDbSkaW12jOOJ
      qlYWh2j15DcgsggiDQ/O06a3R+aIQtO0tpjaHHFgltZWQ5MjC0v85kQtjjwo
      VpiXNDiUkFBjQAADtjFCkQF3eTnEgECGMKocspwvs0FfiUMXU+XntMiJ7E/R
      SK1kSBiw7S518RZihD88dHpegrD/99tH6HeiuM8CL0Xo9uRs4ng/R+hNp3z2
      OkWA0JnTyi6E7j6rDG2CYOdZY9ggWHUxQnkvS1ugkDxB4cNNbFdC2hTB/8DB
      33lKi+FDcphTfwdYOsbP4t01rGuzUwqBJa8HqEOzFLA3tsGb2g==
    EOS
    :dot => <<~EOS,
      eJydl0kWgzAMQ/c+RXfe5QDc/2BlaME4kodk0Qci0o9JoER1jPF52n6m6rRi
      Q1YaJ+ev3ufoqNjiEB8nP/ka0bCXtVU0skZxYvThR7WV0WNzwhEHNADeMXNe
      tehpyEccyDOSGBH0hFqNC0f9xP3Bp3eRzGyIfGtiuItkborIYrlL5MgSkOXF
      XSDHBk4Wb26Ss+50hclkbpHxeraNkWVObTzPiOs1UoiAC2VyhcvIArzh8/cS
      axokI/AHQYCWT3CQJ0ArLrAyF6oYXJnm2gTTOALOp7nDRWQCzsmgCM4F3Rk4
      Ize5s4GCY3KbO1k4OCIvcL0pAHPyEtfZIjAh99YzI4dg/NeyWK8jx2CA3o6N
      gceWP/4fawZ26F9pVqtW6+JysH3Hg6P+Hst8c2Xt2nbp646emtZvsrfKF6H2
      1Bc=
    EOS
  }

  REFS.keys.each do |type|
    define_method(:"test_#{type}") do
      klass = Termlot::Canvas.const_get(type.to_s.capitalize.to_sym)
      c = klass.new(120, 30)
      c.lines!(@x, @sin).lines!(@x, @cos)
      s = StringIO.new
      c.draw(s)
      s.rewind
      out = s.read
      ref = Zlib::Inflate.inflate(Base64.decode64(REFS[type]))
      ref = ref.force_encoding(Encoding::UTF_8)
      assert_equal ref, out
    end
  end

end
