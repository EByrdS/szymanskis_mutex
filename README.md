# Szymański's Mutual Exclusion Algorithm
This algorithm is modeled on a waiting room with an entry and exit doorway.
Initially the entry door is open and the exit door is closed.
All processes which request entry into the critical section at the same time
enter the waiting room; the last of them closes the entry door and opens
the exit door. The processes then enter the critical section one by one.
The last process to leave the critical section closes the exit door and
reopens the entry door so he next batch of processes may enter.
[![Inline docs](http://inch-ci.org/github/EByrdS/szymanskis_mutex.svg?branch=master)](http://inch-ci.org/github/EByrdS/szymanskis_mutex)
## Getting Started
Install the gem or add it to the Gemfile.
```
$ gem install szymanskis_mutex
```

Include the module in the class that will create race conditions or needs
to access the same resource from different threads.
Provide a block containing the critical section to the method
`mutual_exclusion(concern)`. The parameter `concern` is used so that
the class including this module can have different use cases without them
accessing the same variables. (You can have as many separate MutEx as you want.)

```ruby
class RaceConditionReproducer
 include SzymanskisMutex

 @@value = 0

 def mutex_increment
   mutual_exclusion(:add) { unsafe_increment }
 end

 def unsafe_increment
   sleep 2
   temp = @@value

   sleep 2
   temp += 1

   sleep 2
   @@value = temp
 end
end
```

The MutEx will work across different instances of the same class as
it works with class variables.

If you want the MutEx to work across different classes, the module should be
included in the parent class of both or you can create a new class that will
receive the critical section code of both and handle it in the same function.

## Contribution
Pull Requests will be reviewed before merging. Issues are being addressed.
All Pull Requests must contain specs for the changes.
