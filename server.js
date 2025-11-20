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

// Map to track session IDs and their corresponding CSV files
const sessionFiles = {};

// Endpoint to receive game data
app.post('/save_game', (req, res) => {
	try {
		const csvData = req.body;
		console.log('Received game data:');
		console.log(csvData);

		// Extract session_id from CSV data
		const lines = csvData.split('\n');
		let sessionId = null;
		let csvFileName = null;

		if (lines.length >= 2) {
			const headers = lines[0].split(',');
			const values = lines[1].split(',');
			const sessionIdIndex = headers.indexOf('session_id');

			if (sessionIdIndex !== -1 && values[sessionIdIndex]) {
				sessionId = values[sessionIdIndex];
			}
		}

		// If no session_id, use server timestamp
		if (!sessionId) {
			sessionId = `server_${Date.now()}`;
		}

		// Check if we already have a file for this session
		if (!sessionFiles[sessionId]) {
			// Create new file with timestamp in filename
			const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
			csvFileName = `game_${sessionId}_${timestamp}.csv`;
			sessionFiles[sessionId] = csvFileName;
		} else {
			csvFileName = sessionFiles[sessionId];
		}

		// Check if file exists
		const fileExists = fs.existsSync(csvFileName);

		if (!fileExists) {
			// If file doesn't exist, write with headers
			fs.writeFileSync(csvFileName, csvData);
			console.log(`Created new CSV file: ${csvFileName}`);
		} else {
			// If file exists, append only the data row (skip header)
			if (lines.length >= 2) {
				const dataRow = lines[1];
				fs.appendFileSync(csvFileName, dataRow + '\n');
				console.log(`Appended data to ${csvFileName}`);
			}
		}

		res.status(201).json({
			success: true,
			message: 'Game data saved successfully',
			file: csvFileName,
			session_id: sessionId
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
