# Todo app 

Todo application writen in [Odin](https://github.com/odin-lang/Odin) and [Raylib](https://github.com/raysan5/raylib)

Inspired by [Making a Desktop App with a Game Library](https://youtu.be/KSKzaeZJlqk?si=Xl5xMhR-Py_lK8HT)

# Building and running

`build_release.bat` will make a release executable.

`build_debug.bat` will make a debuggable executable.

`run_release.bat` builds and runs the release executable.

`run_debug.bat` builds and runs the debuggable executable.

# Code

Source code is located at `src` folder.

By default tasks are saved to `tasks.json` .

Set **SAVE_TASKS** constant to false to prevent save/load from `tasks.json` .
```Odin
SAVE_TASKS :: true
```