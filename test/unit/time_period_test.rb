require File.dirname(__FILE__) + '/../test_helper'

class TimePeriodTest < ActiveSupport::TestCase

  context 'seconds' do
    should 'return seconds' do
      assert_equal 3600, TimePeriod.seconds(7200)
    end

    should 'return zero if too small number of seconds' do
      assert_equal 0, TimePeriod.seconds(10)
    end
  end

  context 'quantity' do
    should 'return quantity' do
      assert_equal 2, TimePeriod.quantity(7200)
    end

    should 'return zero if too small number of seconds' do
      assert_equal 0, TimePeriod.quantity(10)
    end
  end

  context 'all' do
    should 'return array' do
      assert_instance_of Array, TimePeriod.all
    end
  end

  context 'min seconds' do
    should 'return minimal value of seconds' do
      assert_equal 60, TimePeriod.min_seconds
    end
  end
end
