require 'spec_helper'

describe 'Turbine::VERSION' do
  it { expect(Turbine::VERSION).to be_a(String) }
end
