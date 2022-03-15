# Testing ODGI api

require 'ffi'

module ODGI
  extend FFI::Library
  ffi_lib 'odgi'
  attach_function :load, :odgi_load_graph, [:string], :pointer
  attach_function :free, :odgi_free_graph, [:pointer], :void
  attach_function :version, :odgi_version, [], :string
  attach_function :max_node_id, :odgi_max_node_id, [:pointer], :int
  attach_function :min_node_id, :odgi_min_node_id, [:pointer], :int
  attach_function :count_nodes, :odgi_get_node_count, [:pointer], :int
  attach_function :count_paths, :odgi_get_path_count, [:pointer], :int
  callback :next_path, [:int, :pointer], :void
  attach_function :each_path, :odgi_for_each_path_handle, [:pointer, :next_path], :void
  attach_function :path_name, :odgi_get_path_name, [:pointer, :pointer], :string
end

fn = ARGV.shift

print("Loading #{fn} with ODGI version #{ODGI.version}...\n")

pangenome = ODGI.load(fn)
print("#{ODGI.count_paths(pangenome)} paths\n")
print("#{ODGI.count_nodes(pangenome)} nodes (from #{ODGI.min_node_id(pangenome)} to #{ODGI.max_node_id(pangenome)})\n")
ODGI.each_path(pangenome) { |i,path|
  p [i,path,ODGI.path_name(pangenome,path)]
}
ODGI.free(pangenome) # cleanup
