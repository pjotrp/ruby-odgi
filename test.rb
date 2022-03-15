# Testing ODGI api

require 'ffi'

module ODGI
  extend FFI::Library
  ffi_lib 'odgi'
  attach_function :load, :odgi_load_graph, [:string], :pointer
  attach_function :free, :odgi_free_graph, [:pointer], :int
  attach_function :version, :odgi_version, [], :string
  attach_function :count_nodes, :odgi_get_node_count, [:pointer], :int
  attach_function :count_paths, :odgi_get_path_count, [:pointer], :int
end

fn = ARGV.shift

print("Loading #{fn} with ODGI version #{ODGI.version}...\n")

pangenome = ODGI.load(fn)
print("#{ODGI.count_paths(pangenome)} paths\n")
print("#{ODGI.count_nodes(pangenome)} nodes\n")
ODGI.free(pangenome) # cleanup
