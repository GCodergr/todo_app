package todo_app

import "core:strings"

get_cloned_string :: proc(s: cstring) -> string {
	return strings.clone_from_cstring(s, context.temp_allocator)
}