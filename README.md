# applescript-jira
Applescript utility to automate changing JIRA states

I created this script to make it simple to change ticket states within JIRA.  Our company's state workflow is convoluted, with lots of intermediate states to get from a state like "In Progress" to "Ready for QA".

It allows you to change from a given ticket state to any other reachable state and it automates filling in required data

It can be run from the Agile board (you select ticket to change state for):

![enter image description here](https://raw.githubusercontent.com/dboydor/applescript-jira/master/select_ticket.png)

Or from a specific ticket page:

![enter image description here](https://raw.githubusercontent.com/dboydor/applescript-jira/master/select_state.png)


**Requirements:**

  1. Safari browser
	a. Turn on Develop menu
		* Preferences
		* Advanced Tab
		* Turn on "Show Develop menu in menu bar"
	b. Enable in Develop menu: "Allow Javascript from Apple Events"

  2. Edit Applescript to model your state workflow.  Each top-level state is on the left, and then the transition states and actions to get you there.

    set states to {
    	"REQUIREMENT", {"IN DESIGN", "Start Design"},
    	"BACKLOG(DEV)", {"IN PROGRESS", "Start Dev", "IN DESIGN", "Need Design"},

  3. Modify code further down that deals with which actions have required dialogs (and data entered) that have to be navigated.

    if action is "Start Design" or ...

**Features:**

  1. Can be run from Agile page (and you can select ticket to change state on)
     or from the ticket page

**Keyboard shortcut:**

  1. Easily be done with free Quicksilver app: https://qsapp.com/download.php

**Author:**

   David Boyd 6/18/17
