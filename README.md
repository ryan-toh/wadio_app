# Wadio: Companion App for NSFs

### Video Demo: https://drive.google.com/file/d/1gjpZfNk_c7cxHSKNC_xDgOwXcjOBWZc9/

## Introduction

Built using swift, Wadio is an iOS App used to keep track of how many days a National Serviceman in Singapore has left in service before they are operationally ready, known as the ORD date.


### Main Features

Besides a large ORD counter, the user can keep track of the number of leave days they have left, as well as the number of off days they have earned throughout their NS period.


### IPPT Features

There is also an IPPT scorer, which uses the scoring table for IPPT from MINDEF in order to determine the user's final IPPT score from their push up and sit up counts, as well as their 2.4km run timing.

You can set a goal for your IPPT score and check the number of push ups, sit ups and run timing needed to meet your goal


### UI

Using swiftUI, there is a simple but intuitive navigation system to navigate between the home view and other views.


### How to install

Create a new project in Xcode as a SwiftUI App.
Then, copy and paste the projects into the file.
Run the iPhone/iPad/Any simulator that you wish to test it.
I don't have a paid developer account, so I am unable to preview it without Xcode.

## Documentation and Information

### Project Layout

The main App is in the following files:
- MyApp

The project is spilt into the different views you see.
- ContentView
- IPPTView
- SettingsView
- OnBoardingView

There are companion files used in multiple views, which contain important functions, mainly the conversion of Date types to String types in order to store dates in appStorage (as appStorage does not support storing dates yet).
- DateUtilities

There is also a data folder that contains all the data used for IPPTView, to calculate the final IPPT score and update the latest IPPT score
- agegroup
- pushup
- run
- situp

### Project File Layout

All files are laid out in the following format (including or excluding some sections where relevant)
// MARK: Navigation Layout - How NavigationView is built
// MARK: (viewName) Layout - How the respective view is built
// MARK: UI Layout - How the UI elements are built
// MARK: Logic - Functions

There is a UserData class, as well as an IPPTData class to keep track of user information.
All information in both classes are stored using AppStorage.

### Project File Information

#### ContentView

Features
1. Show ORD date + circular graphic to show progress
Note a. NS has 22 or 24 months

2. Show most recent IPPT score and open a new tab to calculate IPPT score
Note b. the IPPT score combinations are stored in Data.

3. Show number of days to payday and cumulative amount earned from NS
Note c. we need to get the rank and the exact pay amount for each month
Note d. idea: allow user to choose rank and their pay (or enter a custom amount each month)

4. Show the number of remaining leave days
Note a. All NSFs get 14 days of leave every calendar year

#### IPPTView

Features
1: Slider to choose target IPPT Score if clicked
2: UI to calcuate pushup, situp and 2.4km timing
Note a. to show the final IPPT score at the bottom right of the subview as a updating textfield
3: An update button to send to HomeView the latest IPPT score obtained from the textfield


#### SettingsView

Features
1: Edit the Name of the user
2: Edit the remaining leave and off count from the user
3: Edit the Enlistment Date of the user
4: Acknowledgements and credits, version number

#### OnBoardingView
View to onboard the user. Nothing much to see here.

#### DateUtilities

Functions:

DateUtilities.dateToString(date: Date) -> String

Accepts a date of data type "Date" and converts it to a "String".
Return format string: "MMM dd, yyyy"
Example: "Jun 23, 2023"

DateUtilities.StringtoDate(date: String) -> Date
The reverse function of dateToString

Accepts a date of data type "String" and converts it to a "Date".
Input format string: "MMM dd, yyyy"
Example: "Jun 23, 2023"
Return format: a date with type "Date"
