# Testing ODGI api
#
# Note that this file simply reflects the current C-API for odgi. This is the
# basis for a nice Ruby implementation in the future.
#
# At this point I am focussed on a read-only version of the graph.

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
  # handle_t
  callback :next_handle, [:long], :bool
  attach_function :each_handle, :odgi_for_each_handle, [:pointer, :next_handle], :bool
  attach_function :has_node, :odgi_has_node, [:pointer, :long], :bool
  attach_function :get_sequence, :odgi_get_sequence, [:pointer,:long], :string
  attach_function :get_id, :odgi_get_id, [:pointer,:long], :long
  attach_function :get_length, :odgi_get_length, [:pointer,:long], :long
  attach_function :get_is_reverse, :odgi_get_is_reverse, [:pointer,:long], :bool
  callback :next_edge, [:long], :bool
  attach_function :follow_edges, :odgi_follow_edges, [:pointer, :long, :bool, :next_edge], :bool
  # path_handle_t
  callback :next_path, [:long], :void
  attach_function :each_path, :odgi_for_each_path_handle, [:pointer, :next_path], :void
  attach_function :path_name, :odgi_get_path_name, [:pointer, :long], :string
  attach_function :has_path, :odgi_has_path, [:pointer, :string], :bool
  attach_function :get_path, :odgi_get_path_handle, [:pointer, :string], :long
end

fn = ARGV.shift

print("Loading #{fn} with ODGI version #{ODGI.version}...\n")

pangenome = ODGI.load(fn)
print("#{ODGI.count_paths(pangenome)} paths\n")
print("#{ODGI.count_nodes(pangenome)} nodes (from #{ODGI.min_node_id(pangenome)} to #{ODGI.max_node_id(pangenome)})\n")
path_name5 = nil
ODGI.each_path(pangenome) { |path|
  p [path,ODGI.path_name(pangenome,path)]
  path_name5 = ODGI.path_name(pangenome,path) if path==5
}

raise "No path[5]" if not ODGI.has_path(pangenome,path_name5)

path5 = ODGI::get_path(pangenome,path_name5);
p [path5,ODGI.path_name(pangenome,path5)]

ODGI.each_handle(pangenome) { |handle|
  right_edges = []
  ODGI::follow_edges(pangenome,handle,true) { |edge|
    right_edges.push edge
  }
  left_edges = []
  ODGI::follow_edges(pangenome,handle,false) { |edge|
    left_edges.push edge
  }
  p [handle,ODGI::get_id(pangenome,handle),ODGI::get_sequence(pangenome,handle),left_edges,right_edges]
}

ODGI.free(pangenome) # cleanup
