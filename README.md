[![Inline docs](http://inch-ci.org/github/EByrdS/szymanskis_mutex.svg?branch=master)](http://inch-ci.org/github/EByrdS/szymanskis_mutex)
![](https://ruby-gem-downloads-badge.herokuapp.com/szymanskis_mutex?extension=png)
[![MIT license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)
[![Gem](https://img.shields.io/gem/v/szymanskis_mutex.svg?style=flat)](http://rubygems.org/gems/szymanskis_mutex "View this project in Rubygems")
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues)

# Szymański's Mutual Exclusion Algorithm

This algorithm is modeled on a waiting room with an entry and exit doorway.
Initially the entry door is open and the exit door is closed.
All processes which request entry into the critical section at the same time
enter the waiting room; the last of them closes the entry door and opens
the exit door. The processes then enter the critical section one by one.
The last process to leave the critical section closes the exit door and
reopens the entry door so he next batch of processes may enter.

## Getting Started
Install the gem or add it to the Gemfile.
```
$ gem install szymanskis_mutex
```

Provide a block containing the critical section to the class method
`mutual_exclusion(concern)`. The parameter `concern` is used so that
you can have different use cases without them accessing the same variables.
(You can have as many separate MutEx as you want.)

```ruby
class RaceConditionReproducer
 @@value = 0

 def mutex_increment
   SzymanskisMutex.mutual_exclusion(:add) { unsafe_increment }
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

## Contribution
Pull Requests will be reviewed before merging. Issues are being addressed.
All Pull Requests must contain specs for the changes.
