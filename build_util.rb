require 'net/ssh'
require 'logger'
require 'tempfile'
require 'awesome_print'
require 'open3'


def exec(command)
  puts "exec: #{command}"

  #Open3.capture3(command) do |stdout, stderr, status|
  #  puts "in open3"
  #  puts "#{status} #{stdout.chomp} #{stderr.chomp}"
  #end

  Open3.popen2e(command) do |input, stdout_stderr, wait_thr|
    stdout_stderr.each {|line|
      puts line
    }
  end

  puts
end

# Make file
def make_file(file_name, txt)

  puts "make_file: #{file_name}"

  open(file_name, 'w+') { |f|
    f.puts txt
  }

  puts
end





