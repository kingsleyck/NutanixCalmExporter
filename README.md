# NutanixCalmScriptExporter
Export Scripts from Nutanix Calm Blueprints

This is a quick and dirty script for exporting script tasks from Calm blueprints to the filesystem. Committing a changed blueprint to a Git repo doesn't diff well. This script was designed to make it easier to track code changes within a blueprint using a Git repository during the development cycle. 

# Requirements
Powershell 6.1+

# Tested Against
* Calm 2.6.0.4
* Calm 2.7

# Usage
1. Place ExportScripts.ps1 at the root of the repo.
2. Place blueprint json files at the root of the repo.
3. Execute ExportScripts.ps1.
4. Commit and enjoy diffing again.
