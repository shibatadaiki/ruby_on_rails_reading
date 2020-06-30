# frozen_string_literal: true

require_relative "gem_version"

#irb(main):026:0> require "/Users/xxxxxxxxx/rails-master/activemodel/lib/active_model.rb"
#=> true
#irb(main):027:0> ActiveModel.version
#=> #<Gem::Version "6.0.2.2">
module ActiveModel
  # Returns the version of the currently loaded \Active \Model as a <tt>Gem::Version</tt>
  def self.version
    gem_version
  end
end
