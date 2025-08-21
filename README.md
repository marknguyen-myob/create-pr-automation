### Prerequisite
Install and setup git and gh first
Make sure has write permission to repos

### Purpose
- Reduce manual works
- No need to store all repos

### Setup gh cli
1. Install
```
brew install gh
```
2. Verify installation
```
gh --verison
```
3. Login gh cli
```
gh auth login
```

ex:
```
Mark.Nguyen@D5J76CK7L5 create-pr-automation % gh auth login
? Where do you use GitHub? GitHub.com
? What is your preferred protocol for Git operations on this host? HTTPS
? Authenticate Git with your GitHub credentials? Yes
? How would you like to authenticate GitHub CLI? Login with a web browser

! First copy your one-time code: BBF1-F352
Press Enter to open https://github.com/login/device in your browser... 
✓ Authentication complete.
- gh config set -h github.com git_protocol https
✓ Configured git protocol
✓ Logged in as marknguyen-myob
```

### run
Grant execute permission
```
chmod +x ./main.sh
```

Run script
```
main.sh
```