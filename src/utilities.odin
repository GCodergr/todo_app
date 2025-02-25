package todo_app

import "core:strings"
import "core:mem"

get_cloned_string :: proc(s: cstring, allocator: mem.Allocator) -> string {
	return strings.clone_from_cstring(s, allocator)
}