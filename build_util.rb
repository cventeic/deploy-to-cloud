require 'net/ssh'
require 'logger'
require 'tempfile'
require 'awesome_print'
require 'open3'


def exec(command)
  puts "exec: #{command}"

  stdout, stderr, status = Open3.capture3(command)

  #puts stdout.read.chomp
  puts "  status: #{status}"

  puts stdout.chomp
  puts stderr.chomp

  puts
end

# Make file
def make_file(file_name, txt)

  puts "make_file: #{file_name}"

  open(file_name, 'w') { |f|
    f.puts txt
  }

  puts
end





