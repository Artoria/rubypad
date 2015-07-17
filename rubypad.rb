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
    system "#{cmd} #@filename"    
  end

  def run
    while true
      sleep 0.1
      if @mtime != File.mtime(@filename)
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
