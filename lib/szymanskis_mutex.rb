# frozen_string_literal: true

# Copyright (c) 2018, Emmanuel Byrd

# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# Based on the Szymanski's Mutual Exclusion Algorithm
class SzymanskisMutex
  # Metaclass to make code more readable.
  # The only available method to SzymanskisMutex is #mutual_exclusion
  class << self
    # Larger seconds mean less cycles/second but may result in lower completion
    SZYMANSKIS_SLEEP = 0.05

    @@flags = {}
    @@counter = {}

    # Provide a MutEx lock
    # Provide the critical section as a block to this method
    # Different concerns will prevent unrelated code to wait on each other
    def mutual_exclusion(concern)
      @@counter[concern] ||= 0
      @@flags[concern] ||= {}

      # Suppose @@counter += 1 is an atomic function
      my_id = @@counter[concern] += 1

      entry_protocol(concern, my_id)
      begin
        yield
      ensure
        # If something fails in the critical section release the resource
        exit_protocol(concern, my_id)
      end
    end

    private

    # 1: Standing outside waiting room
    # 2: Waiting for other processes to enter
    # 3: Standing in doorway
    # 4: Closed entrance door
    def entry_protocol(concern, id)
      # Standing outside waiting room
      @@flags[concern][id] = 1

      # Wait for open door
      sleep(SZYMANSKIS_SLEEP) while @@flags[concern].values.any? { |f| f > 2 }

      # Stand in doorway
      @@flags[concern][id] = 3

      # Is another process waiting to enter?
      if @@flags[concern].values.any? { |f| f == 1 }

        # Wait for other processes to enter
        @@flags[concern][id] = 2

        # Wait for a process to enter and close the door
        sleep(SZYMANSKIS_SLEEP) while @@flags[concern].values.all? { |f| f != 4 }
      end

      # Close the entrance door
      @@flags[concern][id] = 4

      # Wait for lower ids to finish exit protocol
      while @@flags[concern].select { |i| i < id }.values.any? { |f| f != 1 }
        sleep(SZYMANSKIS_SLEEP)
      end
    end

    # Exit the process and if it is the last one in that batch then
    # reopens the door for the next batch
    def exit_protocol(concern, id)
      # Ensure everyone in the waiting room has realized that the door
      # is supposed to be closed
      while @@flags[concern].select { |i| i > id }.any? { |f| [2, 3].include?(f) }
        sleep(SZYMANSKIS_SLEEP)
      end

      # Leave. This will reopen door if nobody is still in the waiting room
      @@flags[concern].delete(id)

      # If there are processes still running this concern there is
      # nothing else to do
      return unless @@flags[concern].empty?

      # Prevent counter from increasing indefinitely
      @@counter.delete concern
      @@flags.delete concern
    end
  end
end
