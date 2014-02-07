module LoadFixtureHelper
  def load_fixture(name)
    File.read("#{__dir__}/../fixtures/#{name}")
  end
end
