# Testing ODGI api

require 'ffi'

module MyLib
  extend FFI::Library
  ffi_lib 'c'
  attach_function :puts, [ :string ], :int
end

module ODGI
  extend FFI::Library
  ffi_lib 'odgi'
  attach_function :odgi_version, [], :string
  attach_function :odgi_graph_nodes, [], :int
end

MyLib.puts 'Hello, World using libc!'

p "ODGI version: #{ODGI.odgi_version}"
