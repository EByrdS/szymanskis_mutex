require 'spec_helper'

RSpec.describe 'Szymanskis Mutual Exclusion Algorithm' do
  let(:test_class) do
    class RaceConditionReproducer
      include SzymanskisMutex

      @@value = 0

      def value
        @@value
      end

      def mutex_add(concern)
        mutual_exclusion(concern) { unsafe_add }
      end

      def unsafe_add
        sleep 2
        temp = @@value

        sleep 2
        temp += 1

        sleep 2
        @@value = temp
      end

      def reset
        @@value = 0
      end
    end

    RaceConditionReproducer
  end

  it 'can reproduce race condition problem' do
    test_instance = test_class.new
    threads = []
    5.times do
      threads << Thread.new do
        instance = test_class.new
        instance.unsafe_add
      end
    end
    threads.each(&:join)
    expect(test_instance.value).to_not eq 5
  end

  it 'completes code for single instance' do
    test_instance = test_class.new
    expect(test_instance.value).to eq 0
    test_instance.mutex_add(:my_test)
    expect(test_instance.value).to eq 1
  end

  it 'safely executes racing condition' do # It may take a while
    test_instance = test_class.new
    threads = []
    5.times do
      threads << Thread.new do
        instance = test_class.new
        instance.mutex_add(:my_test)
      end
    end
    threads.each(&:join)
    expect(test_instance.value).to eq 5
  end
end
