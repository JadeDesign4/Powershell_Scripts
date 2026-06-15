<#
.SYNOPSIS
    Instantly scaffolds a standardized backend architectural directory structure.
.DESCRIPTION
    NAME:        Scaffold-BackendApp.ps1
    TARGET:      Backend Developers, Sysadmins, & Power Users
    PROBLEM:     Manually setting up directory trees, configs, and dummy files for 
                 new microservices or local testing boilerplate is slow and repetitive.
    USAGE:       .\Scaffold-BackendApp.ps1 -ProjectName "MyNewAPI"
.PARAMETER ProjectName
    The name of the backend folder to create. Defaults to "backend-boilerplate".
#>

param (
    [string]$ProjectName = "backend-boilerplate"
)

Write-Host "🚀 Initiating Backend Scaffolding for: $ProjectName" -ForegroundColor Cyan
Write-Host "--------------------------------------------------"

# 1. Define and create the folder hierarchy
$Directories = @(
    "$ProjectName\config",
    "$ProjectName\src\controllers",
    "$ProjectName\src\models",
    "$ProjectName\src\routes",
    "$ProjectName\src\middleware",
    "$ProjectName\tests",
    "$ProjectName\logs"
)

Write-Host "📁 Creating directory structure..." -ForegroundColor Yellow
foreach ($Dir in $Directories) {
    if (-not (Test-Path $Dir)) {
        New-Item -Path $Dir -ItemType Directory | Out-Null
        Write-Host "   Created: $Dir"
    }
}

# 2. Populate template/placeholder files
Write-Host "📝 Populating template and configuration files..." -ForegroundColor Yellow

# Create a sample config JSON
$JsonContent = @"
{
  "app": {
    "name": "$ProjectName",
    "port": 5000,
    "environment": "development"
  },
  "database": {
    "host": "127.0.0.1",
    "port": 5432,
    "name": "dev_db"
  }
}
"@
Set-Content -Path "$ProjectName\config\default.json" -Value $JsonContent

# Create a standard .env.example
$EnvContent = @"
# Application Configuration
PORT=5000
NODE_ENV=development

# Database Settings
DB_HOST=127.0.0.1
DB_PORT=5432
DB_NAME=dev_db
DB_USER=root
DB_PASSWORD=secret_password
"@
Set-Content -Path "$ProjectName\.env.example" -Value $EnvContent

# Create an entry point boilerplate
$AppContent = @"
// Auto-generated backend application entry point
const express = require('express');
const app = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());

app.get('/health', (req, res) => {
    res.status(200).json({ status: "UP", timestamp: new Date() });
});

app.listen(PORT, () => {
    console.log(\`🚀 Server running smoothly on port \${PORT}\`);
});
"@
Set-Content -Path "$ProjectName\src\app.js" -Value $AppContent

# Create a basic gitignore
$GitignoreContent = @"
.env
logs/
*.log
node_modules/
.DS_Store
"@
Set-Content -Path "$ProjectName\.gitignore" -Value $GitignoreContent

Write-Host "--------------------------------------------------" -ForegroundColor Cyan
Write-Host "✅ Success! Project '$ProjectName' scaffolded beautifully." -ForegroundColor Green
Write-Host "💡 Next steps: 'cd $ProjectName', edit '.env.example', and start coding!" -ForegroundColor Yellow