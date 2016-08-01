require 'FileUtils'
class RubyPad
  include FileUtils
  def initialize(*args)
    @edit     = args[0] || 'notepad'
    @piece    = 0
    @filename = "run.rb"
    touch @filename
    @mtime    = File.mtime @filename
  end
  
  
  def create
    system "cmd /c start #@edit #@filename"
  end

  def runfile
    x = File.read @filename
    cmd = case x.split("\n").first
    when /#!\/usr\/bin\/(.*)/
      $1
    when /#!(.*)/
      $1
    else
      "ruby" 
    end
    rs = "END { open('1.sig', 'wb') do |f| f.write Marshal.dump $LOADED_FEATURES end } \n\#RUBYPAD\n#{x}"
    open("#@filename", "w") do |f| f.write rs end
    system "#{cmd} #@filename"
    open("#@filename", "w") do |f| f.write x end
    r = predefined
    u = r.concat(open("1.sig", "rb") do |f| Marshal.load(f) end.select{|f| FileTest.exists? f})
    if u != @u
      puts "changed"
      puts "new: #{u - (@u || [])}"
      puts "removed: #{(@u ||[]) - u}"
      @u = u
      @v = u.map{|f| File.mtime f}
    end
    @v[0, r.length] = @u[0, r.length].map(&File.method(:mtime))
  end

  def predefined
     [@filename, __FILE__]
  end

  def dep_changed?
    if @u
      v = @u.map{|f| File.mtime f}
      if @v != v
        v.length.times{|i|
          if @v[i] != v[i] 
             puts "#{@u[i]} modified"
          end
        }        
        
        @v = v
        return true
      end
      false
    else
      true
    end
  end

  def run
    while true
      sleep 0.1
      if dep_changed?
        @mtime = File.mtime @filename
        puts "##{@piece += 1}"
        runfile
      end
    end
  end
end


if $0 == __FILE__
  x = RubyPad.new *ARGV
  x.create
  x.run
end
