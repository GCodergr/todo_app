package todo_app

import "core:os"
import "core:fmt"
import "core:encoding/json"
import rl "vendor:raylib"

font : rl.Font
active_input_buffer := [256]u8{}

App_State :: struct {
	tasks : [dynamic]string,
}

app_state : App_State

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720

FONT_SIZE :: 30

// Set to false if you don't want to save tasks to tasks.json
SAVE_TASKS :: true

main :: proc() {
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
	rl.GuiSetStyle(.DEFAULT, cast(i32)rl.GuiDefaultProperty.TEXT_SIZE, FONT_SIZE)	

	font = rl.LoadFontEx("./fonts/JetBrainsMono-Bold.ttf", FONT_SIZE, nil, 250)
	rl.GuiSetFont(font)

	if SAVE_TASKS {
		if app_state_data, ok := os.read_entire_file("tasks.json", context.allocator); ok {
			error := json.unmarshal(app_state_data, &app_state)
			if error != nil {
				fmt.println("Failed to unmarshal application state data.\nError type: ", error)
			}
		} else {
			fmt.println("Failed to read tasks.json file. It will be created on application exit.")
		}
	}	
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
	
	if result == 1 && active_input_buffer[0] != 0 {		
		new_task := get_cloned_string(cstring(&active_input_buffer[0]), context.allocator)
		_, err := append_elem(&app_state.tasks, new_task)
		assert(err == .None)
	}

	STARTING_POSITION_X :: 650
	OFFSET_Y :: 30

	remove_text_width := f32(rl.MeasureText("Remove", FONT_SIZE))

	for task, i in app_state.tasks {
		// Allocate a buffer for the cstring
		task_buffer := make([]u8, len(task) + 1)
		defer delete(task_buffer)

		copy(task_buffer, task)
		// Add null terminator
		task_buffer[len(task)] = 0 
	
		// Convert buffer to cstring
		task_cstring := cstring(&task_buffer[0]) 
		text_width := f32(rl.MeasureText(task_cstring, FONT_SIZE))
		rl.GuiLabel({STARTING_POSITION_X, (f32(i) * 40) + OFFSET_Y, text_width, 30}, 
					task_cstring)

		if rl.GuiButton({WINDOW_WIDTH - remove_text_width - 80, (f32(i) * 40) + OFFSET_Y, 180, 30}, "Remove") {
			ordered_remove(&app_state.tasks, i)
		}
	}	

	rl.EndDrawing()
}

shutdown_app :: proc() {
	if SAVE_TASKS {
		if app_state_data, err := json.marshal(app_state, allocator = context.allocator); err == nil {
			os.write_entire_file("tasks.json", app_state_data)
		}
	}

	rl.UnloadFont(font)
	free_all(context.allocator)
	delete(app_state.tasks)	
}

shutdown_window :: proc() {
	rl.CloseWindow()
}