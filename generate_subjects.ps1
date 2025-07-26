# Requires PowerShell 3.0 or later for advanced features like Get-ChildItem -File

# --- Configuration ---
# Assumes the script is run from the project root (e.g., First-year-guide\)
$ProjectRoot = Get-Location
$PhysicsCycleDir = Join-Path $ProjectRoot "physics-cycle"
$ChemistryCycleDir = Join-Path $ProjectRoot "chemistry-cycle"
$TemplateSubjectDir = Join-Path $PhysicsCycleDir "ma1002-1" # Your master template subject

# List of subjects for Physics Cycle (Code:Full Name)
# Note: MA1002-1 is included here but the script will skip processing it if it's the template.
$PhysicsSubjects = @(
    "MA1002-1:Calculus and Differential Equations" # Included for completeness, but skipped if it's the template
    "PH1004-1:Quantum Computing and Modern Physics"
    "CS1002-1:Problem Solving through Programming"
    "EC1001-2:Basic Electronics"
    "IS1101-1:Fundamentals of Cyber Security"
    "HU1001-1:Technical English"
    "HU1002-1:Constitution of India"
)

# List of subjects for Chemistry Cycle (Code:Full Name)
$ChemistrySubjects = @(
    "MA1007-1:Discrete Mathematics and Transform Techniques"
    "CY1003-1:Materials Chemistry for Computer Systems"
    "EC1002-2:Applied Digital Logic Design"
    "CS1005-2:Introduction to Python programming"
    "EE1001-2:Basic Electrical Engineering"
    "BT1651-1:Biology for Engineers"
    "CV1002-1:Environmental Studies and Sustainability"
)

# --- Functions ---

# Function to process a single subject
function Process-Subject {
    param(
        [string]$SubjectInfo, # e.g., "PH1004-1:Quantum Computing and Modern Physics"
        [string]$CycleDir,    # e.g., "$PhysicsCycleDir"
        [string]$CycleName    # e.g., "Physics Cycle"
    )

    $SubjectCode = $SubjectInfo.Split(':')[0]
    $SubjectName = $SubjectInfo.Split(':')[1]

    Write-Host "Processing $($SubjectCode): $($SubjectName) in $($CycleName)..."

    $NewSubjectDir = Join-Path $CycleDir $SubjectCode

    # Skip copying if the target directory is the template itself (MA1002-1)
    if ($NewSubjectDir -eq $TemplateSubjectDir) {
        Write-Host "  Skipping copy for template subject $($SubjectCode). Assuming it's perfect."
    }
    else {
        # 1. Delete existing folder if it's not the template and recreate
        if (Test-Path $NewSubjectDir) {
            Write-Host "  Removing existing $($NewSubjectDir)..."
            Remove-Item -Path $NewSubjectDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-Host "  Copying template from $($TemplateSubjectDir) to $($NewSubjectDir)..."
        Copy-Item -Path $TemplateSubjectDir -Destination $NewSubjectDir -Recurse -Force
    }

    # 2. Update HTML content
    Write-Host "    Updating HTML content..."
    # Get all index.html files recursively within the new subject directory
    Get-ChildItem -Path $NewSubjectDir -Filter "index.html" -Recurse -File | ForEach-Object {
        $HtmlFile = $_.FullName
        Write-Host "      Updating $($HtmlFile)..."

        # Read file content as a single string (Raw)
        $Content = Get-Content -Path $HtmlFile -Raw -Encoding UTF8

        # Replace subject code
        $Content = $Content -replace 'MA1002-1', $SubjectCode
        
        # Replace subject name
        # Escaping special regex characters in $SubjectName if any (though unlikely for these names)
        $EscapedSubjectName = [regex]::Escape("Calculus and Differential Equations")
        $Content = $Content -replace $EscapedSubjectName, $SubjectName
        
        # Update cycle name if it's Chemistry Cycle
        if ($CycleName -eq "Chemistry Cycle") {
            $Content = $Content -replace '>Physics Cycle<', '>Chemistry Cycle<'
            $Content = $Content -replace 'Physics Cycle Resources', 'Chemistry Cycle Resources'
        }
        else {
            # Ensure Chemistry Cycle is NOT in Physics Cycle files if accidentally copied or modified
            $Content = $Content -replace '>Chemistry Cycle<', '>Physics Cycle<'
            $Content = $Content -replace 'Chemistry Cycle Resources', 'Physics Cycle Resources'
        }

        # Write the modified content back to the file
        Set-Content -Path $HtmlFile -Value $Content -Encoding UTF8
    }

    # 3. Ensure PYQ sub-folders exist and create placeholder PDFs/TXTs
    $PyqDir = Join-Path $NewSubjectDir "pyq"
    $QbDir = Join-Path $NewSubjectDir "qb"
    $HandwrittenNotesDir = Join-Path $NewSubjectDir "handwritten-notes"

    Write-Host "    Ensuring PYQ sub-folders and creating placeholder PDFs/TXTs..."
    New-Item -Path (Join-Path $PyqDir "mse1") -ItemType Directory -Force | Out-Null
    New-Item -Path (Join-Path $PyqDir "mse2") -ItemType Directory -Force | Out-Null
    New-Item -Path (Join-Path $PyqDir "see") -ItemType Directory -Force | Out-Null

    # Create placeholder PDFs/TXTs if they don't exist
    New-Item -Path (Join-Path $PyqDir "mse1" "2024.pdf") -ItemType File -Force | Out-Null
    New-Item -Path (Join-Path $PyqDir "mse1" "2023.pdf") -ItemType File -Force | Out-Null
    New-Item -Path (Join-Path $PyqDir "mse2" "2024.pdf") -ItemType File -Force | Out-Null
    New-Item -Path (Join-Path $PyqDir "mse2" "2023.pdf") -ItemType File -Force | Out-Null
    New-Item -Path (Join-Path $PyqDir "see" "2024.pdf") -ItemType File -Force | Out-Null
    New-Item -Path (Join-Path $PyqDir "see" "2023.pdf") -ItemType File -Force | Out-Null
    New-Item -Path (Join-Path $PyqDir "see" "2022.pdf") -ItemType File -Force | Out-Null

    New-Item -Path (Join-Path $QbDir "unit1.pdf") -ItemType File -Force | Out-Null
    New-Item -Path (Join-Path $QbDir "unit2.pdf") -ItemType File -Force | Out-Null
    New-Item -Path (Join-Path $QbDir "unit3.pdf") -ItemType File -Force | Out-Null
    
    New-Item -Path (Join-Path $HandwrittenNotesDir "module1-notes.pdf") -ItemType File -Force | Out-Null
    New-Item -Path (Join-Path $HandwrittenNotesDir "module2-notes.txt") -ItemType File -Force | Out-Null
    New-Item -Path (Join-Path $HandwrittenNotesDir "full-syllabus.pdf") -ItemType File -Force | Out-Null

    Write-Host "Finished $($SubjectCode)."
    Write-Host "---"
}

# --- Main Script Execution ---
Write-Host "Starting subject generation script from $($ProjectRoot)..."

# Process Physics Cycle subjects
foreach ($subject in $PhysicsSubjects) {
    Process-Subject -SubjectInfo $subject -CycleDir $PhysicsCycleDir -CycleName "Physics Cycle"
}

# Process Chemistry Cycle subjects
foreach ($subject in $ChemistrySubjects) {
    # Ensure Chemistry Cycle directory exists before processing subjects within it
    if (-not (Test-Path $ChemistryCycleDir)) {
        New-Item -Path $ChemistryCycleDir -ItemType Directory -Force | Out-Null
    }
    Process-Subject -SubjectInfo $subject -CycleDir $ChemistryCycleDir -CycleName "Chemistry Cycle"
}

Write-Host "Script finished. All subjects generated/updated."
Write-Host "Please verify content in your browser and then commit changes to Git."
Write-Host "e.g., git add . ; git commit -m \"Automated generation of all subject structures\" ; git push origin main"