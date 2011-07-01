#require 'test/unit'

require 'rubygems'
require 'benchmark'

require './lib/cfpropertylist'

n = 1000000
array = ['object'] * n
enum = ['object'].cycle(n)
Benchmark.bm do |x|
  x.report('array') {
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(array)
    plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  }
  x.report('enumerator') {
    plist = CFPropertyList::List.new
    plist.value = CFPropertyList.guess(enum)
    plist.to_str(CFPropertyList::List::FORMAT_BINARY)
  }
end
