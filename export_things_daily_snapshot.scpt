-- Things Daily Snapshot Export to JSON
-- Exports open tasks, active projects, and recent completions
-- Output: ~/Documents/ThingsSnapshot/YYYY-MM-DD_things_snapshot.json

-- Helper function to escape strings for JSON
on escapeJSON(theText)
	if theText is missing value or theText is "" then return ""
	set theText to searchReplace(theText, "\\", "\\\\")
	set theText to searchReplace(theText, "\"", "\\\"")
	set theText to searchReplace(theText, (ASCII character 10), "\\n")
	set theText to searchReplace(theText, (ASCII character 13), "\\r")
	set theText to searchReplace(theText, (ASCII character 9), "\\t")
	return theText
end escapeJSON

-- Helper function for search and replace
on searchReplace(theText, searchString, replaceString)
	set AppleScript's text item delimiters to searchString
	set textItems to text items of theText
	set AppleScript's text item delimiters to replaceString
	set theText to textItems as text
	set AppleScript's text item delimiters to ""
	return theText
end searchReplace

-- Helper function to format date as ISO 8601
on formatDate(theDate)
	if theDate is missing value then return "null"
	set y to year of theDate as string
	set m to text -2 thru -1 of ("0" & (month of theDate as integer))
	set d to text -2 thru -1 of ("0" & day of theDate)
	set h to text -2 thru -1 of ("0" & hours of theDate)
	set min to text -2 thru -1 of ("0" & minutes of theDate)
	set s to text -2 thru -1 of ("0" & seconds of theDate)
	return "\"" & y & "-" & m & "-" & d & "T" & h & ":" & min & ":" & s & "Z\""
end formatDate

-- Helper function to get tag names
on getTagNames(theTags)
	set tagList to {}
	repeat with aTag in theTags
		set end of tagList to "\"" & escapeJSON(name of aTag) & "\""
	end repeat
	return "[" & my joinList(tagList, ", ") & "]"
end getTagNames

-- Helper function to join list items
on joinList(theList, delimiter)
	set AppleScript's text item delimiters to delimiter
	set theString to theList as string
	set AppleScript's text item delimiters to ""
	return theString
end joinList

-- Helper function to safely get area name
on getAreaName(theTask)
	try
		if area of theTask is not missing value then
			return name of area of theTask
		else
			return ""
		end if
	on error
		return ""
	end try
end getAreaName

-- Helper function to safely get project name
on getProjectName(theTask)
	try
		if project of theTask is not missing value then
			return name of project of theTask
		else
			return ""
		end if
	on error
		return ""
	end try
end getProjectName

-- Main script
try
	-- Check if Things3 is running, launch if needed
	if not (application "Things3" is running) then
		tell application "Things3" to launch
		delay 2 -- Give Things3 time to fully launch
	end if
end try

tell application "Things3"

	-- Calculate date range for completed tasks (last 14 days)
	set fourteenDaysAgo to (current date) - (14 * days)

	-- Initialize JSON arrays
	set openTasksJSON to {}
	set activeProjectsJSON to {}
	set completedTasksJSON to {}

	-- ========================================
	-- OPEN TASKS (excluding completed/canceled)
	-- ========================================
	-- Get all tasks that aren't completed or canceled
	set openTasks to to dos whose status is not completed and status is not canceled

	repeat with aTask in openTasks
		-- Get basic properties
		set taskName to name of aTask
		set taskNotes to notes of aTask
		set taskStatus to status of aTask as string

		-- Get area and project names safely
		set areaName to my getAreaName(aTask)
		set projectName to my getProjectName(aTask)

		-- Get dates
		set taskActivationDate to my formatDate(activation date of aTask)
		set taskDueDate to my formatDate(due date of aTask)
		set taskCreationDate to my formatDate(creation date of aTask)
		set taskModificationDate to my formatDate(modification date of aTask)

		-- Get tags
		set taskTags to my getTagNames(tags of aTask)

		-- Build JSON object
		set taskJSON to "{" & ¬
			"\"name\": \"" & my escapeJSON(taskName) & "\", " & ¬
			"\"status\": \"" & taskStatus & "\", " & ¬
			"\"area\": \"" & my escapeJSON(areaName) & "\", " & ¬
			"\"project\": \"" & my escapeJSON(projectName) & "\", " & ¬
			"\"notes\": \"" & my escapeJSON(taskNotes) & "\", " & ¬
			"\"tags\": " & taskTags & ", " & ¬
			"\"activation_date\": " & taskActivationDate & ", " & ¬
			"\"due_date\": " & taskDueDate & ", " & ¬
			"\"creation_date\": " & taskCreationDate & ", " & ¬
			"\"modification_date\": " & taskModificationDate & ¬
			"}"

		set end of openTasksJSON to taskJSON
	end repeat

	-- ========================================
	-- ACTIVE PROJECTS (excluding completed)
	-- ========================================
	set activeProjects to projects whose status is not completed and status is not canceled

	repeat with aProject in activeProjects
		set projectName to name of aProject
		set projectStatus to status of aProject as string

		-- Get area name safely
		set areaName to my getAreaName(aProject)

		set projectNotes to notes of aProject
		set projectTags to my getTagNames(tags of aProject)
		set projectDueDate to my formatDate(due date of aProject)

		-- Count tasks in project
		set projectTasks to to dos of aProject
		set taskCount to count of projectTasks
		set openTaskCount to 0
		repeat with t in projectTasks
			if status of t is not completed and status of t is not canceled then
				set openTaskCount to openTaskCount + 1
			end if
		end repeat

		set projectJSON to "{" & ¬
			"\"name\": \"" & my escapeJSON(projectName) & "\", " & ¬
			"\"status\": \"" & projectStatus & "\", " & ¬
			"\"area\": \"" & my escapeJSON(areaName) & "\", " & ¬
			"\"notes\": \"" & my escapeJSON(projectNotes) & "\", " & ¬
			"\"tags\": " & projectTags & ", " & ¬
			"\"due_date\": " & projectDueDate & ", " & ¬
			"\"total_tasks\": " & taskCount & ", " & ¬
			"\"open_tasks\": " & openTaskCount & ¬
			"}"

		set end of activeProjectsJSON to projectJSON
	end repeat

	-- ========================================
	-- COMPLETED TASKS (last 14 days)
	-- ========================================
	set completedTasks to to dos whose status is completed and completion date ≥ fourteenDaysAgo

	repeat with aTask in completedTasks
		set taskName to name of aTask

		-- Get area and project names safely
		set areaName to my getAreaName(aTask)
		set projectName to my getProjectName(aTask)

		set taskTags to my getTagNames(tags of aTask)
		set taskCompletionDate to my formatDate(completion date of aTask)
		set taskCreationDate to my formatDate(creation date of aTask)

		set taskJSON to "{" & ¬
			"\"name\": \"" & my escapeJSON(taskName) & "\", " & ¬
			"\"area\": \"" & my escapeJSON(areaName) & "\", " & ¬
			"\"project\": \"" & my escapeJSON(projectName) & "\", " & ¬
			"\"tags\": " & taskTags & ", " & ¬
			"\"completion_date\": " & taskCompletionDate & ", " & ¬
			"\"creation_date\": " & taskCreationDate & ¬
			"}"

		set end of completedTasksJSON to taskJSON
	end repeat

end tell

-- ========================================
-- BUILD FINAL JSON
-- ========================================
set generatedAt to my formatDate(current date)
set todayString to do shell script "date +%Y-%m-%d"

set finalJSON to "{" & ¬
	"\"generated_at\": " & generatedAt & ", " & ¬
	"\"date\": \"" & todayString & "\", " & ¬
	"\"open_tasks\": [" & my joinList(openTasksJSON, ", ") & "], " & ¬
	"\"active_projects\": [" & my joinList(activeProjectsJSON, ", ") & "], " & ¬
	"\"completed_tasks_14d\": [" & my joinList(completedTasksJSON, ", ") & "]" & ¬
	"}"

-- ========================================
-- WRITE TO FILE
-- ========================================
set outputDir to POSIX path of (path to home folder) & "Library/Mobile Documents/com~apple~CloudDocs/kb/ThingsSnapshot/"
set outputFile to outputDir & todayString & "_things_snapshot.json"

-- Create directory if needed
do shell script "mkdir -p " & quoted form of outputDir

-- Write JSON to file
try
	set fileRef to open for access POSIX file outputFile with write permission
	try
		set eof fileRef to 0
		write finalJSON to fileRef as «class utf8»
	on error errMsg
		close access fileRef
		error "Failed to write JSON: " & errMsg
	end try
	close access fileRef
on error errMsg
	try
		close access fileRef
	end try
	error "Failed to open file for writing: " & errMsg
end try

return "Export complete: " & outputFile
