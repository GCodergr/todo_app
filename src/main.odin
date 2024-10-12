package todo_app

import rl "vendor:raylib"

active_input_buffer := [256]u8{}
tasks := [dynamic]string{}

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720

main :: proc(){
	init_window()
	init_app()

	for app_update() {}
		
	shutdown_app()
	shutdown_window()
}

init_window :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})	
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Todo App")
	rl.SetWindowPosition(rl.GetScreenWidth() - WINDOW_WIDTH / 2, 
						 rl.GetScreenHeight() - WINDOW_HEIGHT / 2)
	rl.SetTargetFPS(144)
}

init_app :: proc() {
	rl.GuiSetStyle(.DEFAULT, cast(i32)rl.GuiDefaultProperty.TEXT_SIZE, 30)	
}

app_update :: proc() -> bool {	
	draw()
	return !rl.WindowShouldClose()
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.SKYBLUE)

	secret_view := true
	result := rl.GuiTextInputBox({10, 30, 600, 300}, "Input todo tasks", "Enter a Task", "Add", 
								cstring(&active_input_buffer[0]), 256, &secret_view)
	
	if result == 1 {
		new_task := get_cloned_string(cstring(&active_input_buffer[0]))
		_, err := append_elem(&tasks, new_task)
		assert(err == .None)
	}

	STARTING_POSITION_X :: 650
	OFFSET_Y :: 30

	remove_text_width := f32(rl.MeasureText("Remove", 30))

	for task, i in tasks {
		// Allocate a buffer for the cstring
		task_buffer := make([]u8, len(task) + 1)
		defer delete(task_buffer)

		copy(task_buffer, task)
		// Add null terminator
		task_buffer[len(task)] = 0 
	
		// Convert buffer to cstring
		task_cstring := cstring(&task_buffer[0]) 
		text_width := f32(rl.MeasureText(task_cstring, 30))
		rl.GuiLabel({STARTING_POSITION_X, (f32(i) * 40) + OFFSET_Y, text_width, 30}, 
					task_cstring)

		if rl.GuiButton({WINDOW_WIDTH - remove_text_width - 80, (f32(i) * 40) + OFFSET_Y, 180, 30}, "Remove") {
			ordered_remove(&tasks, i)
		}
	}	

	rl.EndDrawing()
}

shutdown_app :: proc() {
	delete(tasks)	
}

shutdown_window :: proc() {
	rl.CloseWindow()
}