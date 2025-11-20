# Transform Tetris Feature Additions - Claude Code Task List
## For Claude Haiku 4.5 Execution

**Project**: Transform Tetris  
**Engine**: Godot 4.5  
**Language**: GDScript (tabs for indentation, NOT spaces)  
**Platform**: Desktop/HTML5

**Note**: This task list adds two new features to an existing Transform Tetris game:
1. Integer translation input (custom X/Y values)
2. CSV game data saving to server

---

## PHASE 1: UI Foundation for Custom Translation

**Goal**: Add UI elements for entering custom X and Y translation values

### Task 1.1: Add Translation Input Variables
**Dependencies**: None  
	**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. Open `res://scripts/game.gd`
2. Locate the UI variables section (around line 50, after `var panel_size : int = 10`)
3. Add these three new variable declarations BELOW the existing UI variables:
   ```gdscript
   # New UI elements for custom translation input
   var translate_x_input : LineEdit			  # input field for X translation
   var translate_y_input : LineEdit			  # input field for Y translation
   ```
4. Use tabs for indentation (NOT spaces)
5. Save the file

**Human Checkpoint**:
- [ ] Script runs without errors (F6 to test)
- [ ] New variables declared after `panel_size` variable
- [ ] Variables use tabs for indentation
- [ ] Variable names match exactly: `translate_x_input` and `translate_y_input`

---

### Task 1.2: Create Translation Input UI Elements
**Dependencies**: Task 1.1  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. Open `res://scripts/game.gd`
2. Locate the `_create_ui()` function (around line 98)
3. Find the line `panel_size += 30` after `ui_vbox.add_child(mode_checkbox)`
4. IMMEDIATELY AFTER that section and BEFORE the `_button_y = 100.0` line, add this code:
   ```gdscript
   	# Add separator label
   	var sep_label = Label.new()
   	sep_label.text = "--- Custom Translation ---"
   	ui_vbox.add_child(sep_label)
   	panel_size += 30
   	
   	# Create input fields for custom translation
   	var x_container = HBoxContainer.new()
   	var x_label = Label.new()
   	x_label.text = "X: "
   	x_container.add_child(x_label)
   	
   	translate_x_input = LineEdit.new()
   	translate_x_input.placeholder_text = "0"
   	translate_x_input.custom_minimum_size = Vector2(60, 0)
   	x_container.add_child(translate_x_input)
   	ui_vbox.add_child(x_container)
   	panel_size += 30
   	
   	var y_container = HBoxContainer.new()
   	var y_label = Label.new()
   	y_label.text = "Y: "
   	y_container.add_child(y_label)
   	
   	translate_y_input = LineEdit.new()
   	translate_y_input.placeholder_text = "0"
   	translate_y_input.custom_minimum_size = Vector2(60, 0)
   	y_container.add_child(translate_y_input)
   	ui_vbox.add_child(y_container)
   	panel_size += 30
   ```
5. Use tabs for indentation (NOT spaces)
6. Save the file

**Human Checkpoint**:
- [ ] Script runs without errors (F6)
- [ ] Run game and verify two input fields appear in UI panel with labels "X:" and "Y:"
- [ ] Input fields show placeholder text "0"
- [ ] Section header "--- Custom Translation ---" appears above inputs

---

### Task 1.3: Add Custom Translate Button
**Dependencies**: Task 1.2  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. Open `res://scripts/game.gd`
2. In the `_create_ui()` function, locate the code you just added for the Y input container
3. IMMEDIATELY AFTER the `panel_size += 30` line (after the Y container), add:
   ```gdscript
   	
   	# Add custom translate button
   	_add_button("Translate T(x,y)", "_on_custom_translate")
   ```
4. Now locate the existing button creation lines (T(-1,0), T(1,0), etc.)
5. BEFORE the first `_add_button` call (the T(-1,0) button), add a separator:
   ```gdscript
   	
   	# Add separator label
   	var sep_label2 = Label.new()
   	sep_label2.text = "--- Quick Actions ---"
   	ui_vbox.add_child(sep_label2)
   	panel_size += 30
   ```
6. Use tabs for indentation
7. Save the file

**Human Checkpoint**:
- [ ] Script runs without errors (F6)
- [ ] Run game and verify "Translate T(x,y)" button appears below the Y input field
- [ ] Verify "--- Quick Actions ---" header appears above the T(-1,0) button
- [ ] Button is visible and clickable (will show error when clicked - this is expected)

---

### Task 1.4: Implement Custom Translation Handler
**Dependencies**: Task 1.3  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. Open `res://scripts/game.gd`
2. Locate the button callback functions section (around line 290, after `_on_mode_toggled()` function)
3. BEFORE the `_on_move_left()` function, add this new function:
   ```gdscript
   func _on_custom_translate() -> void:
   	# Read values from input fields and apply translation
   	var x_text = translate_x_input.text.strip_edges()
   	var y_text = translate_y_input.text.strip_edges()
   	
   	# Validate inputs
   	if not x_text.is_valid_int():
   		print("Invalid X value: must be an integer")
   		return
   	if not y_text.is_valid_int():
   		print("Invalid Y value: must be an integer")
   		return
   	
   	var dx = x_text.to_int()
   	var dy = y_text.to_int()
   	
   	_apply_translation(dx, dy)
   	
   	# Clear input fields after successful translation
   	translate_x_input.text = ""
   	translate_y_input.text = ""
   ```
4. Use tabs for indentation
5. Save the file

**Human Checkpoint**:
- [ ] Script runs without errors (F6)
- [ ] Run game, enter "2" in X field and "0" in Y field, click "Translate T(x,y)"
- [ ] Piece moves 2 cells to the right (if valid)
- [ ] Input fields clear after translation
- [ ] Invalid input (like "abc") prints error to console and doesn't crash

---

## PHASE 2: Server Communication Foundation

**Goal**: Add HTTP communication capabilities and session tracking

### Task 2.1: Add Server Communication Variables
**Dependencies**: None  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. Open `res://scripts/game.gd`
2. Locate the line with `var piece_timer : Timer` (around line 55)
3. IMMEDIATELY AFTER that line, add these new variable declarations:
   ```gdscript
   var http_request : HTTPRequest				# for sending data to server
   
   # Server configuration
   var server_url : String = "http://localhost:3000/save_game"  # Change this to your server URL
   var session_id : String = ""				  # unique ID for this game session
   var game_start_time : float = 0.0			 # timestamp when game started
   var pieces_dropped : int = 0				  # total pieces dropped this session
   var total_transforms : int = 0				# total transformations across all pieces
   ```
4. Use tabs for indentation
5. Save the file

**Human Checkpoint**:
- [ ] Script runs without errors (F6)
- [ ] All new variables declared after `piece_timer`
- [ ] Variables use tabs for indentation
- [ ] Default server URL is set to localhost:3000

---

### Task 2.2: Initialize HTTP Request Node and Session
**Dependencies**: Task 2.1  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. Open `res://scripts/game.gd`
2. Locate the `_ready()` function (around line 60)
3. IMMEDIATELY AFTER the `_init_board()` line and BEFORE the `piece_timer` section, add:
   ```gdscript
   	# Generate a unique session ID
   	session_id = _generate_session_id()
   	game_start_time = Time.get_unix_time_from_system()
   ```
4. Then locate the `piece_timer.connect()` line
5. IMMEDIATELY AFTER that line and BEFORE `_create_ui()`, add:
   ```gdscript
   	
   	# Create HTTPRequest node for server communication
   	http_request = HTTPRequest.new()
   	add_child(http_request)
   	http_request.connect("request_completed", Callable(self, "_on_http_request_completed"))
   ```
6. Use tabs for indentation
7. Save the file

**Human Checkpoint**:
- [ ] Script runs without errors (F6)
- [ ] HTTPRequest node is created when game starts
- [ ] No error messages in console about missing functions (we'll add them next)

---

### Task 2.3: Implement Session ID Generator
**Dependencies**: Task 2.2  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. Open `res://scripts/game.gd`
2. Locate the `_ready()` function
3. IMMEDIATELY AFTER the closing brace of `_ready()` function (around line 78), add:
   ```gdscript
   
   func _generate_session_id() -> String:
   	# Generate a unique session ID using timestamp and random number
   	var timestamp = Time.get_unix_time_from_system()
   	var random_part = randi() % 10000
   	return "session_%d_%d" % [timestamp, random_part]
   ```
4. Use tabs for indentation
5. Save the file

**Human Checkpoint**:
- [ ] Script runs without errors (F6)
- [ ] Run game and check console - no errors about missing `_generate_session_id()`
- [ ] Session ID is generated on game start (you can add a print statement to verify)

---

### Task 2.4: Add Transform Counter to Transformation Functions
**Dependencies**: Task 2.1  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. Open `res://scripts/game.gd`
2. Locate the `_apply_translation()` function (around line 200)
3. Find the line `transform_count += 1` inside this function
4. IMMEDIATELY AFTER that line, add:
   ```gdscript
   		total_transforms += 1
   ```
5. Now locate the `_apply_rotation()` function (around line 210)
6. Find the line `transform_count += 1` inside this function
7. IMMEDIATELY AFTER that line, add:
   ```gdscript
   		total_transforms += 1
   ```
8. Now locate the `_apply_reflection()` function (around line 225)
9. Find the line `transform_count += 1` inside this function
10. IMMEDIATELY AFTER that line, add:
	```gdscript
			total_transforms += 1
	```
11. Use tabs for indentation
12. Save the file

**Human Checkpoint**:
- [ ] Script runs without errors (F6)
- [ ] All three transformation functions have `total_transforms += 1` added
- [ ] Indentation matches the existing `transform_count += 1` line

---

### Task 2.5: Update Piece Drop Counter
**Dependencies**: Task 2.1  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. Open `res://scripts/game.gd`
2. Locate the `_drop_piece()` function (around line 245)
3. Find the section that calculates `lines` and updates the score
4. AFTER the score update logic and BEFORE `_update_score_label()`, add:
   ```gdscript
   	
   	pieces_dropped += 1
   ```
5. Use tabs for indentation
6. Save the file

**Human Checkpoint**:
- [ ] Script runs without errors (F6)
- [ ] Run game, drop a few pieces
- [ ] `pieces_dropped` counter increments (you can verify by adding a temporary print statement)

---

## PHASE 3: Data Saving Implementation

**Goal**: Implement functions to prepare game data and send to server

### Task 3.1: Add Save Button to UI
**Dependencies**: Task 1.3  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. Open `res://scripts/game.gd`
2. Locate the UI variables section where you added `translate_x_input` and `translate_y_input`
3. Add one more variable declaration:
   ```gdscript
   var save_button : Button					  # manual save button
   ```
4. Now locate the `_create_ui()` function
5. Find the last `_add_button` call (the "Drop" button)
6. AFTER all the existing `_add_button` calls, add:
   ```gdscript
   	
   	# Add separator label
   	var sep_label3 = Label.new()
   	sep_label3.text = "--- Data Management ---"
   	ui_vbox.add_child(sep_label3)
   	panel_size += 30
   	
   	# Add save button
   	save_button = Button.new()
   	save_button.text = "Save to Server"
   	save_button.size = Vector2(120, 32)
   	save_button.connect("pressed", Callable(self, "_on_save_to_server"))
   	ui_vbox.add_child(save_button)
   	panel_size += 30
   ```
7. Use tabs for indentation
8. Save the file

**Human Checkpoint**:
- [ ] Script runs without errors (F6)
- [ ] Run game and verify "Save to Server" button appears at bottom of UI
- [ ] "--- Data Management ---" header appears above button
- [ ] Button shows error when clicked (expected - we'll add the function next)

---

### Task 3.2: Implement Game Data Preparation Function
**Dependencies**: Task 2.1  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. Open `res://scripts/game.gd`
2. Locate the `_on_drop()` function (around line 335)
3. IMMEDIATELY AFTER the `_on_drop()` function, add these two new functions:
   ```gdscript
   
   func _on_save_to_server() -> void:
   	# Prepare game data and send to server
   	var game_data = _prepare_game_data()
   	_send_to_server(game_data)
   
   func _prepare_game_data() -> Dictionary:
   	# Prepare game statistics as a dictionary
   	var current_time = Time.get_unix_time_from_system()
   	var play_duration = current_time - game_start_time
   	
   	return {
   		"session_id": session_id,
   		"timestamp": Time.get_datetime_string_from_system(),
   		"score": score,
   		"pieces_dropped": pieces_dropped,
   		"total_transforms": total_transforms,
   		"mode": "timed" if timed_mode else "untimed",
   		"play_duration_seconds": play_duration,
   		"avg_transforms_per_piece": float(total_transforms) / max(pieces_dropped, 1)
   	}
   ```
4. Use tabs for indentation
5. Save the file

**Human Checkpoint**:
- [ ] Script runs without errors (F6)
- [ ] Functions compile without syntax errors
- [ ] Dictionary includes all 8 fields: session_id, timestamp, score, pieces_dropped, total_transforms, mode, play_duration_seconds, avg_transforms_per_piece

---

### Task 3.3: Implement CSV Conversion Function
**Dependencies**: Task 3.2  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. Open `res://scripts/game.gd`
2. Locate the `_prepare_game_data()` function you just added
3. IMMEDIATELY AFTER that function, add:
   ```gdscript
   
   func _dict_to_csv(data: Dictionary) -> String:
   	# Convert dictionary to CSV format
   	# First line: headers, second line: values
   	var headers = []
   	var values = []
   	
   	for key in data.keys():
   		headers.append(key)
   		values.append(str(data[key]))
   	
   	var csv = ",".join(headers) + "\n"
   	csv += ",".join(values) + "\n"
   	
   	return csv
   ```
4. Use tabs for indentation
5. Save the file

**Human Checkpoint**:
- [ ] Script runs without errors (F6)
- [ ] Function compiles without syntax errors
- [ ] Function returns a string with two lines (headers and values)

---

### Task 3.4: Implement HTTP Send Function
**Dependencies**: Task 3.3  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. Open `res://scripts/game.gd`
2. Locate the `_dict_to_csv()` function you just added
3. IMMEDIATELY AFTER that function, add:
   ```gdscript
   
   func _send_to_server(data: Dictionary) -> void:
   	# Convert dictionary to CSV format
   	var csv_data = _dict_to_csv(data)
   	
   	# Prepare HTTP headers
   	var headers = [
   		"Content-Type: text/csv",
   		"Accept: application/json"
   	]
   	
   	# Send POST request
   	var error = http_request.request(
   		server_url,
   		headers,
   		HTTPClient.METHOD_POST,
   		csv_data
   	)
   	
   	if error != OK:
   		print("Error sending data to server: ", error)
   	else:
   		print("Data sent to server successfully")
   		save_button.disabled = true  # Prevent duplicate saves
   ```
4. Use tabs for indentation
5. Save the file

**Human Checkpoint**:
- [ ] Script runs without errors (F6)
- [ ] Function compiles without syntax errors
- [ ] HTTP request is configured with POST method and CSV content type

---

### Task 3.5: Implement HTTP Response Handler
**Dependencies**: Task 3.4  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. Open `res://scripts/game.gd`
2. Locate the `_send_to_server()` function you just added
3. IMMEDIATELY AFTER that function, add:
   ```gdscript
   
   func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
   	# Handle server response
   	if response_code == 200 or response_code == 201:
   		print("Server saved data successfully!")
   		save_button.text = "Saved ✓"
   	else:
   		print("Server error: ", response_code)
   		var response_body = body.get_string_from_utf8()
   		print("Response: ", response_body)
   		save_button.disabled = false  # Re-enable on error
   ```
4. Use tabs for indentation
5. Save the file

**Human Checkpoint**:
- [ ] Script runs without errors (F6)
- [ ] Function compiles without syntax errors
- [ ] Handler checks for success codes (200 or 201)
- [ ] Button text changes to "Saved ✓" on success

---

## PHASE 4: Server Setup and Testing

**Goal**: Set up backend server to receive CSV data

### Task 4.1: Create Node.js Server File
**Dependencies**: None (parallel-safe)  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. Create a new file `server.js` in your project directory (NOT in the Godot project, in a separate folder)
2. Add this complete server code:
   ```javascript
   // Simple Node.js server to receive and save Transform Tetris game data
   
   const express = require('express');
   const cors = require('cors');
   const fs = require('fs');
   const path = require('path');
   
   const app = express();
   const PORT = 3000;
   const CSV_FILE = 'game_data.csv';
   
   // Enable CORS for Godot game
   app.use(cors());
   
   // Parse text/csv content type
   app.use(express.text({ type: 'text/csv' }));
   
   // Endpoint to receive game data
   app.post('/save_game', (req, res) => {
   	try {
   		const csvData = req.body;
   		console.log('Received game data:');
   		console.log(csvData);
   		
   		// Check if file exists
   		const fileExists = fs.existsSync(CSV_FILE);
   		
   		if (!fileExists) {
   			// If file doesn't exist, write with headers
   			fs.writeFileSync(CSV_FILE, csvData);
   			console.log(`Created new CSV file: ${CSV_FILE}`);
   		} else {
   			// If file exists, append only the data row (skip header)
   			const lines = csvData.split('\n');
   			if (lines.length >= 2) {
   				const dataRow = lines[1];
   				fs.appendFileSync(CSV_FILE, dataRow + '\n');
   				console.log(`Appended data to ${CSV_FILE}`);
   			}
   		}
   		
   		res.status(201).json({ 
   			success: true, 
   			message: 'Game data saved successfully',
   			file: CSV_FILE
   		});
   		
   	} catch (error) {
   		console.error('Error saving game data:', error);
   		res.status(500).json({ 
   			success: false, 
   			error: error.message 
   		});
   	}
   });
   
   // Health check endpoint
   app.get('/health', (req, res) => {
   	res.json({ 
   		status: 'ok',
   		message: 'Transform Tetris server is running',
   		csvFile: CSV_FILE
   	});
   });
   
   // Start server
   app.listen(PORT, () => {
   	console.log(`Transform Tetris server running on http://localhost:${PORT}`);
   	console.log(`Game data will be saved to: ${path.resolve(CSV_FILE)}`);
   	console.log('\nEndpoints:');
   	console.log(`  POST /save_game - Save game data`);
   	console.log(`  GET  /health    - Check server status`);
   });
   ```
3. Save the file

**Human Checkpoint**:
- [ ] File `server.js` created successfully
- [ ] All code is properly formatted
- [ ] Server listens on port 3000
- [ ] Has POST /save_game endpoint

---

### Task 4.2: Create package.json for Node.js Dependencies
**Dependencies**: Task 4.1  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. In the same directory as `server.js`, create `package.json`
2. Add this content:
   ```json
   {
   	"name": "transform-tetris-server",
   	"version": "1.0.0",
   	"description": "Server for receiving and saving Transform Tetris game data in CSV format",
   	"main": "server.js",
   	"scripts": {
   		"start": "node server.js"
   	},
   	"dependencies": {
   		"express": "^4.18.2",
   		"cors": "^2.8.5"
   	}
   }
   ```
3. Save the file
4. In terminal, navigate to the directory and run: `npm install`

**Human Checkpoint**:
- [ ] File `package.json` created successfully
- [ ] `npm install` completes without errors
- [ ] `node_modules` folder created with express and cors

---

### Task 4.3: Test Server Startup
**Dependencies**: Task 4.2  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. In terminal, navigate to the server directory
2. Run: `node server.js`
3. Verify console output shows:
   - "Transform Tetris server running on http://localhost:3000"
   - "Game data will be saved to: [path]/game_data.csv"
   - Lists of endpoints
4. Keep server running for next test

**Human Checkpoint**:
- [ ] Server starts without errors
- [ ] Console shows correct startup messages
- [ ] Server is listening on port 3000
- [ ] No error messages in console

---

### Task 4.4: End-to-End Integration Test
**Dependencies**: All previous tasks  
**Extended thinking**: OFF  
**Reminder**: Before starting, ask the human: "Is extended thinking on? For this task, it should be **OFF**."

**Implementation**:
1. Ensure Node.js server is running (`node server.js`)
2. Launch the Godot game (F5)
3. Play for 30 seconds:
   - Move some pieces using T(-1,0), T(1,0) buttons
   - Try custom translation: enter X=3, Y=0, click "Translate T(x,y)"
   - Drop a few pieces
4. Click "Save to Server" button
5. Check server console for "Received game data:" message
6. Check that `game_data.csv` file was created in server directory
7. Open `game_data.csv` and verify it contains game statistics

**Human Checkpoint**:
- [ ] Game runs without errors
- [ ] Custom translation input works correctly
- [ ] "Save to Server" button sends data successfully
- [ ] Server receives data and prints it to console
- [ ] `game_data.csv` file created with correct headers
- [ ] CSV contains: session_id, timestamp, score, pieces_dropped, total_transforms, mode, play_duration_seconds, avg_transforms_per_piece
- [ ] Second save appends new row without duplicating headers

---

## COMPLETION

All tasks complete! The Transform Tetris game now has:

✅ **Custom translation input** - Enter any integer X/Y values  
✅ **CSV server save** - Game statistics saved to server in CSV format

**Next Steps for Human**:
1. Test various translation values (positive, negative, large numbers)
2. Verify data accuracy in CSV file
3. Consider adding auto-save after each piece drop
4. Consider deploying server to production environment
5. Add data visualization/analysis tools

**Files Modified**:
- `res://scripts/game.gd` - Updated with all new features

**Files Created**:
- `server.js` - Node.js backend server
- `package.json` - Node.js dependencies
- `game_data.csv` - Auto-generated by server

**Key Features**:
- All code uses tabs for indentation (as specified)
- Type hints on all new functions
- Comprehensive error handling
- User-friendly UI layout
- Modular, testable code
