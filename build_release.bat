@echo off

odin build src -out:todo_app_release.exe -strict-style -vet -no-bounds-check -o:speed -subsystem:windows
