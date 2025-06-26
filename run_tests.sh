#!/bin/bash
# Zeit Test Runner Script

echo "Running Zeit tests..."
cmd.exe /c "cd /d C:\\Users\\himaj\\project-win\\Zeit && C:\\Users\\himaj\\project-win\\Zeit\\Godot_v4.4.1-stable_win64.exe\\Godot_v4.4.1-stable_win64.exe --headless test/test_runner_scene.tscn"
exit_code=$?
echo "Tests completed with exit code: $exit_code"
exit $exit_code