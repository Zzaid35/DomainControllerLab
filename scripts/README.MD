# Scripts

| Script | What it does |
|---|---|
| onboarding.ps1 | Onboards new Employees using the given CSV of new employee details |
| Offboarding.ps1 | Disabled Employees accounts & Moves them to the disabled users group |
| Current-Employees.ps1 | Compiles a list/CSV of all the current employees in the company. |

## Onboarding.ps1
- Input: Reads `user.csv` from `C:\Shares\Scripts` with each new employee's first name, last name, department, and level. Prompts for a temporary password when run, so no password is ever stored in the script or the CSV.
- What it does: Builds each username from the first and last name, creates the account in the matching department OU with the temporary password, and requires a password change at first sign-in. It then adds the user to their department's security group based on their level (for example, `Sales Manager Security`), which gives them their file share access.
                                                                                                                                                                                                                                                                                    
## Offboarding.ps1
- Input: Reads `user.csv` from `C:\Shares\Scripts` with each departing employee's first name, last name, and department.
- What it does: Builds each username from the first and last name, disables the account, moves it to the Disabled Users OU, and removes it from every group except Domain Users. Each offboarding is logged with the username, department, and date to `C:\Shares\Logs\Offboarding.txt`.

## Current-Employees.ps1
- Input: None. Reads every user account under the `ZaidCo\Users` OU in Active Directory.
- What it does: Collects each user's name, username, department, and title, and exports the list to `CurrentlyEmployed.csv`. Offboarded accounts live in the Disabled Users OU, so they're automatically left out of the report.
