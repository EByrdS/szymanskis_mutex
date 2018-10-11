require 'spec_helper'

RSpec.describe SzymanskisMutex do
  let(:test_class) do
    class RaceConditionReproducer

      @@value = 0

      def value
        @@value
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
    described_class.mutual_exclusion(:my_test) { test_instance.unsafe_add }
    expect(test_instance.value).to eq 1
  end

  it 'safely executes racing condition' do # It may take a while
    test_instance = test_class.new
    threads = []
    5.times do
      threads << Thread.new do
        instance = test_class.new
        described_class.mutual_exclusion(:my_test) { instance.unsafe_add }
      end
    end
    threads.each(&:join)
    expect(test_instance.value).to eq 5
  end
end
