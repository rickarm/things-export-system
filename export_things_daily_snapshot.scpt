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

-- Helper function to calculate days between dates
on daysBetween(fromDate, toDate)
	if fromDate is missing value or toDate is missing value then return "null"
	set timeDiff to toDate - fromDate
	set daysDiff to round (timeDiff / days) rounding down
	return daysDiff as string
end daysBetween

-- Helper function to check if date is today or past
on isDateTodayOrPast(theDate)
	if theDate is missing value then return false
	set todayMidnight to (current date)
	set hours of todayMidnight to 0
	set minutes of todayMidnight to 0
	set seconds of todayMidnight to 0
	return theDate ≤ todayMidnight
end isDateTodayOrPast

-- Helper function to check if task is overdue
on isOverdue(theDueDate)
	if theDueDate is missing value then return false
	set now to current date
	return theDueDate < now
end isOverdue

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

		-- Get dates (raw values for calculations)
		set taskScheduledDate to activation date of aTask
		set taskDueDate to due date of aTask
		set taskCreationDate to creation date of aTask
		set taskModificationDate to modification date of aTask

		-- Get tags
		set taskTags to my getTagNames(tags of aTask)

		-- Calculate AI-friendly metadata
		set nowDate to current date
		set isInToday to my isDateTodayOrPast(taskScheduledDate)
		set isTaskOverdue to my isOverdue(taskDueDate)

		-- Days until due (null if no due date)
		set daysUntilDue to "null"
		if taskDueDate is not missing value then
			set daysUntilDue to my daysBetween(nowDate, taskDueDate)
		end if

		-- Days since scheduled (null if no scheduled date)
		set daysSinceScheduled to "null"
		if taskScheduledDate is not missing value then
			set daysSinceScheduled to my daysBetween(taskScheduledDate, nowDate)
		end if

		-- Format dates as ISO strings
		set taskScheduledDateStr to my formatDate(taskScheduledDate)
		set taskDueDateStr to my formatDate(taskDueDate)
		set taskCreationDateStr to my formatDate(taskCreationDate)
		set taskModificationDateStr to my formatDate(taskModificationDate)

		-- Build JSON object
		set taskJSON to "{" & ¬
			"\"name\": \"" & my escapeJSON(taskName) & "\", " & ¬
			"\"status\": \"" & taskStatus & "\", " & ¬
			"\"area\": \"" & my escapeJSON(areaName) & "\", " & ¬
			"\"project\": \"" & my escapeJSON(projectName) & "\", " & ¬
			"\"notes\": \"" & my escapeJSON(taskNotes) & "\", " & ¬
			"\"tags\": " & taskTags & ", " & ¬
			"\"scheduled_date\": " & taskScheduledDateStr & ", " & ¬
			"\"due_date\": " & taskDueDateStr & ", " & ¬
			"\"creation_date\": " & taskCreationDateStr & ", " & ¬
			"\"modification_date\": " & taskModificationDateStr & ", " & ¬
			"\"is_in_today\": " & (isInToday as string) & ", " & ¬
			"\"is_overdue\": " & (isTaskOverdue as string) & ", " & ¬
			"\"days_until_due\": " & daysUntilDue & ", " & ¬
			"\"days_since_scheduled\": " & daysSinceScheduled & ¬
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

-- Build field guide for AI understanding
set fieldGuide to "{" & ¬
	"\"scheduled_date\": \"Start date - when you plan to BEGIN this task (appears in Today on this date)\", " & ¬
	"\"due_date\": \"Deadline - when this task must be COMPLETED\", " & ¬
	"\"is_in_today\": \"Boolean - is this task's scheduled date today or earlier?\", " & ¬
	"\"is_overdue\": \"Boolean - is this task past its deadline?\", " & ¬
	"\"days_until_due\": \"Integer - days remaining until deadline (negative if overdue, null if no deadline)\", " & ¬
	"\"days_since_scheduled\": \"Integer - days since the task became active (null if not yet scheduled)\"" & ¬
	"}"

set finalJSON to "{" & ¬
	"\"schema_version\": \"2.0\", " & ¬
	"\"generated_at\": " & generatedAt & ", " & ¬
	"\"date\": \"" & todayString & "\", " & ¬
	"\"field_guide\": " & fieldGuide & ", " & ¬
	"\"open_tasks\": [" & my joinList(openTasksJSON, ", ") & "], " & ¬
	"\"active_projects\": [" & my joinList(activeProjectsJSON, ", ") & "], " & ¬
	"\"completed_tasks_14d\": [" & my joinList(completedTasksJSON, ", ") & "]" & ¬
	"}"

-- ========================================
-- WRITE TO FILE
-- ========================================
-- CONFIGURATION: Change this path to your preferred export location
-- Examples:
--   iCloud: "Library/Mobile Documents/com~apple~CloudDocs/ThingsExports/"
--   Local: "Documents/ThingsSnapshot/"
--   Dropbox: "Dropbox/ThingsExports/"
set outputDir to POSIX path of (path to home folder) & "Documents/ThingsSnapshot/"
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
