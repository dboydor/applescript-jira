--- An Applescript to automate the tedious workflow within JIRA.
---
--- It allows you to change from a given ticket state to any other
--- reachable state and it automates filling in required data
---
--- It can be run from the Agile board (you select ticket to
--- change state for) or from a specific ticket page.
---
--- Requirements:
---
---   1. Safari browser
---		a. Turn on Develop menu
---			* Preferences
---			* Advanced Tab
---			* Turn on "Show Develop menu in menu bar"
---		b. Enable in Develop menu: "Allow Javascript from Apple Events"
---
--- Features:
---
---   1. Can be run from Agile page (and you can select ticket to change state on)
---      or from the ticket page
---
--- Keyboard shortcut:
---
---   1. Easily be done with free Quicksilver app: https://qsapp.com/download.php
---
--- Author:
---
---    David Boyd 6/18/17
---

--- Values required for "Sent for Build" action dialog
set developerAssigned to "na"
set developerReviewerDevLead to "na"

set useHardcodedStates to true

--- Data structure modelling states and actions in JIRA
set states to {¬
	"REQUIREMENT", {"IN DESIGN", "Start Design"}, ¬
	"BACKLOG(DEV)", {"IN PROGRESS", "Start Dev", "IN DESIGN", "Need Design"}, ¬
	"IN DESIGN", {"IN DESIGN REVIEW", "Sent for Design Review"}, ¬
	"IN DESIGN REVIEW", {"IN DESIGN", "Need Design Rework", "BACKLOG(DEV)", "Design Approved"}, ¬
	"IN DEV REVIEW", {"UX AUDIT", "Sent for UX Audit", "WAITING FOR BUILD", "Sent for Build"}, ¬
	"DEV UNIT TEST", {"IN DEV REVIEW", "Sent for Dev Review"}, ¬
	"UX AUDIT", {"IN DEV REVIEW", "UX Audit completed"}, ¬
	"IN PROGRESS", {"DEV UNIT TEST", "Unit Testing", "IN DEV REVIEW", "Sent for Dev Review"}, ¬
	"WAITING FOR BUILD", {"READY FOR DEV TEST", "Build Done"}, ¬
	"READY FOR DEV TEST", {"READY FOR QA", "Dev Tested"}, ¬
	"READY FOR QA", {"QA IN PROGRESS", "QA takes over"}, ¬
	"QA IN PROGRESS", {"QA Blocked", "QA Blocked", "CLOSED", "QA Verified", "READY FOR PRODUCTION", "QA Complete"}, ¬
	"QA BLOCKED", {"QA IN PROGRESS", "QA Resumed"}, ¬
	"QA REJECTED", {"IN PROGRESS", "Rework on Code"}, ¬
	"READY FOR PRODUCTION", {"CLOSED", "Deployed"}, ¬
	"CLOSED", {"BACKLOG(DEV)", "Re-Open"}}

set statesDirect to {¬
	"ARCHIVE", "Archive", ¬
	"DUPLICATE", "Duplicate", ¬
	"HIBERNATED", "Hibernated", ¬
	"CLOSED", "Closed"}

set statesTo to {¬
	"BACKLOG(DEV)", ¬
	"IN PROGRESS", ¬
	"IN DEV REVIEW", ¬
	"WAITING FOR BUILD", ¬
	"READY FOR DEV TEST", ¬
	"READY FOR QA", ¬
	"CLOSED"}

set statesToLabel to {¬
	"Backlog", ¬
	"In Progress", ¬
	"Code Complete", ¬
	"Merged", ¬
	"Dev Testing", ¬
	"QA", ¬
	"Done"}

--- Another workflow for bug tickets
set states_SPR_Workflow to {¬
	"REQUIREMENT", {"BACKLOG(DEV)", "Queue for Dev"}, ¬
	"OPEN", {"BACKLOG(DEV)", "Queue for Dev"}, ¬
	"BACKLOG(DEV)", {"IN PROGRESS", "Start", "OPEN", "Need More Info"}, ¬
	"IN PROGRESS", {"IN DEV REVIEW", "Sent for Dev Review"}, ¬
	"IN DEV REVIEW", {"IN PROGRESS", "Need Dev Rework", "WAITING FOR BUILD", "Ready for Build"}, ¬
	"WAITING FOR BUILD", {"READY FOR QA", "Build Done"}, ¬
	"READY FOR QA", {"QA IN PROGRESS", "Start QA"}, ¬
	"QA IN PROGRESS", {"QA REJECTED", "Reject", "CLOSED", "QA Verified", "READY FOR PRODUCTION", "QA Complete"}, ¬
	"QA REJECTED", {"IN PROGRESS", "Rework on Code"}, ¬
	"READY FOR PRODUCTION", {"CLOSED", "Deployed"}, ¬
	"CLOSED", {"BACKLOG(DEV)", "Re-Open"}}

set statesTo_SPR_Workflow to {¬
	"BACKLOG(DEV)", ¬
	"IN PROGRESS", ¬
	"IN DEV REVIEW", ¬
	"WAITING FOR BUILD", ¬
	"READY FOR QA", ¬
	"CLOSED"}

set statesToLabel_SPR_Workflow to {¬
	"Backlog", ¬
	"In Progress", ¬
	"Code Complete", ¬
	"Merged", ¬
	"QA", ¬
	"Done"}

--- Another workflow for support tickets
set states_L3_Support_Workflow to {¬
	"REQUIREMENT", {"BACKLOG(DEV)", "Queue for Dev"}, ¬
	"NEED CONFIRMATION", {"BACKLOG(DEV)", "Issue Confirmed", "OPEN", "Need More Info"}, ¬
	"BACKLOG(DEV)", {"IN PROGRESS", "Start", "NEED CONFIRMATION", "Need More Info"}, ¬
	"IN PROGRESS", {"IN DEV REVIEW", "Sent for Dev Review"}, ¬
	"IN DEV REVIEW", {"IN PROGRESS", "Need Dev Rework", "WAITING FOR BUILD", "Ready for Build"}, ¬
	"WAITING FOR BUILD", {"READY FOR QA", "Build Done"}, ¬
	"READY FOR QA", {"QA IN PROGRESS", "Start QA"}, ¬
	"QA IN PROGRESS", {"QA REJECTED", "Reject", "CLOSED", "QA Verified", "READY FOR PRODUCTION", "QA Complete"}, ¬
	"QA REJECTED", {"IN PROGRESS", "Rework on Code"}, ¬
	"READY FOR PRODUCTION", {"CLOSED", "Deployed"}, ¬
	"CLOSED", {"BACKLOG(DEV)", "Re-Open"}}

set statesTo_L3_Support_Workflow to {¬
	"NEEDS CONFIRMATION", ¬
	"BACKLOG(DEV)", ¬
	"IN PROGRESS", ¬
	"IN DEV REVIEW", ¬
	"WAITING FOR BUILD", ¬
	"READY FOR QA", ¬
	"CLOSED"}

set statesToLabel_L3_Support_Workflow to {¬
	"Requirements", ¬
	"Backlog", ¬
	"In Progress", ¬
	"Code Complete", ¬
	"Merged", ¬
	"QA", ¬
	"Done"}

--- Another workflow for support tickets
set states_Release_Manual_Workflow to {¬
	"REQUIREMENT", {"IN DESIGN", "Start Design"}, ¬
	"IN DESIGN", {"BACKLOG(DEV)", "Queue for Dev"}, ¬
	"BACKLOG(DEV)", {"IN PROGRESS", "Start Dev"}, ¬
	"IN DEV REVIEW", {"UX AUDIT", "Sent for UX Audit", "WAITING FOR BUILD", "Sent for Build"}, ¬
	"DEV UNIT TEST", {"IN DEV REVIEW", "Sent for Dev Review"}, ¬
	"UX AUDIT", {"IN DEV REVIEW", "UX Audit completed"}, ¬
	"IN PROGRESS", {"DEV UNIT TEST", "Unit Testing", "IN DEV REVIEW", "Sent for Dev Review"}, ¬
	"WAITING FOR BUILD", {"READY FOR DEV TEST", "Build Done"}, ¬
	"READY FOR DEV TEST", {"READY FOR QA", "Dev Tested"}, ¬
	"READY FOR QA", {"QA IN PROGRESS", "QA takes over"}, ¬
	"QA IN PROGRESS", {"QA Blocked", "QA Blocked", "CLOSED", "QA Verified", "READY FOR PRODUCTION", "QA Complete"}, ¬
	"QA BLOCKED", {"QA IN PROGRESS", "QA Resumed"}, ¬
	"QA REJECTED", {"IN PROGRESS", "Rework on Code"}, ¬
	"READY FOR PRODUCTION", {"CLOSED", "Deployed"}, ¬
	"CLOSED", {"BACKLOG(DEV)", "Re-Open"}}

set statesTo_Release_Manual_Workflow to {¬
	"BACKLOG(DEV)", ¬
	"IN PROGRESS", ¬
	"IN DEV REVIEW", ¬
	"WAITING FOR BUILD", ¬
	"READY FOR DEV TEST", ¬
	"READY FOR QA", ¬
	"CLOSED"}

set statesToLabel_Release_Manual_Workflow to {¬
	"Backlog", ¬
	"In Progress", ¬
	"Code Complete", ¬
	"Merged", ¬
	"Dev Testing", ¬
	"QA", ¬
	"Done"}

set browserUrl to browserGetUrl()
log browserUrl

set createdTab to false

--- Select from a list of tickets on our Agile board
if browserUrl does not contain "/DISPLAY-" then
	set tickets to browserGetTickets()
	set ticket to choose from list tickets with prompt "Choose a JIRA ticket:"

	if ticket is false then
		error number -128 (* user cancelled *)
	else
		set ticket to ticket's item 1 (* extract choice from list *)
	end if

	--- Open the selected ticket in a new tab
	browserOpenTicket(getId(ticket))

	set createdTab to true
end if

--- display dialog "You choose: " & ticket

--- If SPR Bug Workflow, then use different set of states
if browserIsWorkflow("=SPR+Bug+Workflow") is true then
	set states to states_SPR_Workflow
	set statesTo to statesTo_SPR_Workflow
	set statesToLabel to statesToLabel_SPR_Workflow
end if

--- If L3 Support Workflow, then use different set of states
if browserIsWorkflow("=L3+Support+Workflow") is true then
	set states to states_L3_Support_Workflow
	set statesTo to statesTo_L3_Support_Workflow
	set statesToLabel to statesToLabel_L3_Support_Workflow
end if

--- If Release Manual Workflow, then use different set of states
if browserIsWorkflow("=Release+Manual") is true then
	set states to states_Release_Manual_Workflow
	set statesTo to statesTo_Release_Manual_Workflow
	set statesToLabel to statesToLabel_Release_Manual_Workflow
end if

set stateFrom to browserGetState()

if useHardcodedStates is true then
	set availableStates to statesToLabel
else
	--- Get all the states that are reachable from this current state
	set availableStates to sortArray(getStatePath(states, stateFrom))
	set stateFrom to stringUpper(stateFrom)
end if

set stateTo to choose from list availableStates with prompt "Current ticket state is:
" & stateFrom & "

Change to:"

if stateTo is false then
	--- Close the tab we created after we're done
	if createdTab is true then
		browserCloseTab(browserUrl)
	end if

	error number -128 (* user cancelled *)
else if useHardcodedStates is true then
	set foundOffset to findArray(statesToLabel, stateTo)
	--- Wasn't working until I made it two-step assignment
	set newState to (item foundOffset of statesTo as string)
	set stateTo to newState
end if

set actionPath to getActionPath(states, stateFrom, stringTrimTrailing(stateTo))
log actionPath

set i to 1
repeat until i > (count of actionPath)
	set action to item i of actionPath

	repeat while getAction(action) is ""
		delay 1
	end repeat

	--- log "FOUND ACTION ID: " & getAction(action)
	browserClickById(getAction(action))

	log "Performing action: " & action

	if action is "Start Design" or ¬
		action is "Sent for Design Review" or ¬
		action is "Design Approved" or ¬
		action is "Issue Confirmed" or ¬
		action is "Start" or ¬
		action is "Start Dev" or ¬
		action is "Sent for Dev Review" or ¬
		action is "Sent for Build" or ¬
		action is "Ready for Build" or ¬
		action is "Dev Tested" or ¬
		action is "QA Complete" or ¬
		action is "QA Verified" or ¬
		action is "Deployed" or ¬
		action is "Re-Open" then

		--- Wait until dialog appears
		repeat while browserDialogOpen() is false
			delay 1
		end repeat

		--- Do some required form things for these actions
		if action is "Design Approved" then
			repeat while browserGetCheckbox("No") is ""
				delay 1
			end repeat

			browserCheckById(browserGetCheckbox("No"))
		end if

		if action is "Sent for Build" or action is "Ready for Build" then
			repeat while browserGetCheckbox("None") is ""
				delay 1
			end repeat

			browserSetTextArea("Assigned Developer(s)", developerAssigned)
			browserSetTextArea("Reviewer/Dev Lead", developerReviewerDevLead)
			browserCheckById(browserGetCheckbox("None"))
		end if

		if action is "Start" then
			repeat while browserGetCheckbox("None") is ""
				delay 1
			end repeat

			browserSetTextArea("Story Points", "1")
		end if

		--- Click and wait until dialog disappears
		repeat while browserDialogOpen() is true
			browserClickById("issue-workflow-transition-submit")
			delay 1
		end repeat
	end if

	--- error number -128

	set i to i + 1
end repeat

--- Close the tab we created after we're done
if createdTab is true then
	browserCloseTab(browserUrl)
end if

(* ==== FUNCTIONS ==== *)
(* ==== FUNCTIONS ==== *)
(* ==== FUNCTIONS ==== *)

on browserGetTickets()
	set tickets to {}
	set pos to 0

	repeat while browserGetTicket(pos) starts with "DISPLAY"
		set the end of tickets to browserGetTicket(pos)
		set pos to pos + 1
	end repeat

	return tickets
end browserGetTickets

on browserGetTicket(pos)
	tell application "Safari"
		tell front window
			tell current tab
				set ticket to do JavaScript "
					var issues = document.getElementsByClassName('ghx-issue');
					if (" & (pos) & " < issues.length) {
					  document.getElementsByClassName('ghx-issue')[" & (pos) & "].attributes['data-issue-key'].value + ': ' +
					  document.getElementsByClassName('ghx-issue')[" & (pos) & "].children[0].attributes['data-tooltip'].value;
					} else {
					  'NA';
					}"
			end tell
		end tell
	end tell

	return ticket
end browserGetTicket

on browserGetUrl()
	set browserUrl to ""

	tell application "Safari"
		tell front window
			tell current tab
				set browserUrl to URL
			end tell
		end tell
	end tell

	return browserUrl
end browserGetUrl

on browserCloseTab(browserUrl)
	tell application "Safari"
		tell front window
			close current tab
			set current tab to (first tab whose URL contains browserUrl)
		end tell
	end tell
end browserCloseTab

on browserClickById(id)
	tell application "Safari"
		tell front window
			tell current tab
				do JavaScript "document.getElementById('" & id & "').click()"
			end tell
		end tell
	end tell
end browserClickById

on browserCheckById(id)
	tell application "Safari"
		tell front window
			tell current tab
				do JavaScript "document.getElementById('" & id & "').checked = true"
			end tell
		end tell
	end tell
end browserCheckById

on browserGetState()
	tell application "Safari"
		tell front window
			tell current tab
				set result to do JavaScript "document.getElementById('status-val').children[0].innerHTML;"
			end tell
		end tell
	end tell

	return result
end browserGetState

on browserOpenTicket(ticketId)
	tell application "Safari"
		--- activate
		tell front window
			set current tab to (make new tab with properties {URL:"https://sprinklr.atlassian.net/browse/" & ticketId})
			delay 2
		end tell
	end tell
end browserOpenTicket

on browserGetCheckbox(value)
	set checkId to ""

	tell application "Safari"
		tell front window
			tell current tab
				set cmd to "
          var list = document.querySelectorAll('div.checkbox');
          var x = list.length;
          while (x--) {
              if (list[x].children[1].innerHTML === '" & value & "') {
				var result = list[x].children[0].attributes['id'].value;
				!result ? '' : result;
				break;
              }
          }

          if (x === -1) '';"
				set checkId to do JavaScript cmd
			end tell
		end tell
	end tell

	if checkId as string is "missing value" then
		set checkId to ""
	end if

	return checkId
end browserGetCheckbox

on browserSetTextArea(label, value)
	tell application "Safari"
		tell front window
			tell current tab
				set cmd to "
        var list = document.querySelectorAll('label');
        var x = list.length;
        while (x--) {
            if (list[x].innerHTML === '" & label & "') {
                var id = list[x].attributes['for'].value;
                document.getElementById(id).value = '" & value & "';
                break;
            }
        }"
				set result to do JavaScript cmd
			end tell
		end tell
	end tell

	return result
end browserSetTextArea

on browserIsWorkflow(workflow)
	tell application "Safari"
		tell front window
			tell current tab
				set cmd to "
          document.querySelectorAll(\"a[href*='" & workflow & "']\").length === 0 ? false : true"
				set result to do JavaScript cmd
			end tell
		end tell
	end tell

	return result
end browserIsWorkflow

on browserDialogOpen()
	tell application "Safari"
		tell front window
			tell current tab
				set cmd to "
          document.getElementsByClassName('jira-dialog-open').length === 0 ? false : true"
				set result to do JavaScript cmd
			end tell
		end tell
	end tell

	return result
end browserDialogOpen

on getAction(actionName)
	set actions to {}
	set pos to 0

	repeat while getActionId(pos) starts with "action"
		if getActionName(pos) is actionName then
			return getActionId(pos)
		end if
		set pos to pos + 1
	end repeat

	return ""
end getAction

on getActionId(pos)
	tell application "Safari"
		tell document 1
			set result to do JavaScript "var element = document.getElementsByClassName('issueaction-workflow-transition')[" & (pos) & "]; element.attributes['id'].value;"
		end tell
	end tell

	return stringTrimTrailing(result)
end getActionId

on getActionName(pos)
	tell application "Safari"
		tell document 1
			set result to do JavaScript "var element = document.getElementsByClassName('issueaction-workflow-transition')[" & (pos) & "]; element.children[0].innerHTML;"
		end tell
	end tell
	return stringTrimTrailing(result)
end getActionName

--- Fetch just the ticket number using sed
on getId(value)
	set cmd to "echo \"" & value & "\" | sed \"s/.*\\(DISPLAY-[0-9]*\\).*/\\1/\"" as string
	set ticketId to do shell script cmd
	return ticketId
end getId

on getStatePath(states, stateFrom)
	return getStatePathDepth(states, stateFrom, 0, {}, stateFrom)
end getStatePath

on getStatePathDepth(states, stateFrom, depth, stateList, stateExclude)
	set itemStates to getStateItems(states, stateFrom)
	set i to 1

	--- Easy cycle detector. Set to # of states we have.
	if depth > 15 then
		return stateList
	end if

	--- log "from:" & stateFrom & " to: " & stateTo & ", depth: " & depth

	repeat until i > (count of itemStates)
		set subState to item i of itemStates

		if findArray(stateList, subState) is -1 then
			if subState is not stateExclude then
				set stateList to stateList & subState
			end if
			set stateList to getStatePathDepth(states, subState, depth + 1, stateList, stateExclude)
		end if

		set i to i + 2
	end repeat

	return stateList
end getStatePathDepth

on getStatePath2(states, stateFrom, stateTo)
	return rest of getStatePathDepth2(states, stateFrom, stateTo, 0)
	--- return getStatePathDepth2(states, stateFrom, stateTo, 0)
end getStatePath2

on getStatePathDepth2(states, stateFrom, stateTo, depth)
	set itemStates to getStateItems(states, stateFrom)
	set i to 1
	set found to {9999, "DUMMY"}

	--- Easy cycle detector. Set to # of states we have.
	if depth > 15 then
		return found
	end if

	--- log "from:" & stateFrom & " to: " & stateTo & ", depth: " & depth

	repeat until i > (count of itemStates)
		set subState to item i of itemStates

		if subState is stateTo then
			return {depth} & subState
		else
			set find to getStatePathDepth2(states, subState, stateTo, depth + 1)
			set findDepth to item 1 of find
			if findDepth is not 9999 then
				if item 1 of found > item 1 of find then
					set found to find
					set foundStates to rest of found
					set foundStates to {subState} & foundStates
					set found to item 1 of found & foundStates
				end if
			end if
		end if
		set i to i + 2
	end repeat

	--- log "found: " & found

	return found
end getStatePathDepth2

on getActionPath(states, stateFrom, stateTo)
	return rest of getActionPathDepth(states, stateFrom, stateTo, 0)
	--- return getActionPathDepth(states, stateFrom, stateTo, 0)
end getActionPath

on getActionPathDepth(states, stateFrom, stateTo, depth)
	set itemStates to getStateItems(states, stateFrom)
	set i to 1
	set found to {9999, "DUMMY"}

	--- Easy cycle detector. Set to # of states we have.
	if depth > 15 then
		return found
	end if

	if depth is 0 then
		log "from:" & stateFrom & " to: " & stateTo & ", depth: " & depth
	end if

	repeat until i > (count of itemStates)
		set subState to item i of itemStates
		set subAction to item (i + 1) of itemStates

		if subState is stateTo then
			return {depth} & subAction
		else
			set find to getActionPathDepth(states, subState, stateTo, depth + 1)
			set findDepth to item 1 of find
			if findDepth is not 9999 then
				if item 1 of found > item 1 of find then
					set found to find
					set foundActions to rest of found
					set foundActions to {subAction} & foundActions
					set found to item 1 of found & foundActions
				end if
			end if
		end if
		set i to i + 2
	end repeat

	--- log "found: " & found

	return found
end getActionPathDepth

on getStateItems(states, match)
	set stateItems to {}
	set i to 1

	repeat until i > (count of states)
		if item i of states is match then return item (i + 1) of states
		set i to i + 2
	end repeat

	return stateItems
end getStateItems

on findArray(source, value)
	set i to 1

	repeat until i > (count of source)
		set sourceItem to item i of source as string

		if sourceItem is value as string then
			return i
		end if

		set i to i + 1
	end repeat

	return -1
end findArray

on sortArray(source)
	set saveDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to {ASCII character 10} -- always a linefeed
	set listString to (source as string)
	set newString to do shell script "echo " & quoted form of listString & " | sort -f"
	set newList to (paragraphs of newString)
	set AppleScript's text item delimiters to saveDelims
	return newList
end sortArray

on stringTrimSpaces(value)
	set cmd to "echo \"" & value & "\" | tr -d ' '" as string
	set result to do shell script cmd
	return result
end stringTrimSpaces

on stringUpper(value)
	set cmd to "echo \"" & value & "\" | tr '[:lower:]' '[:upper:]'" as string
	set result to do shell script cmd
	return result
end stringUpper

on stringTrimTrailing(value)
	set checker to value as string
	set cmd to ("echo " & quoted form of checker) & " | sed -e 's/[[:space:]]*$//'" as string
	set result to do shell script cmd
	return result
end stringTrimTrailing