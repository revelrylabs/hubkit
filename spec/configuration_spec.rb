require 'spec_helper'

describe Hubkit::Configuration do
  it 'throws NoMethodError if an unknown method is called' do
    expect { Hubkit::Configuration.x_y_z }.to raise_error(NoMethodError)
  end
end
