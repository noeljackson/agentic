# Desktop Organization

Organize the user's Desktop by:
1. Moving Downloads contents to Desktop
2. Deleting app installers (.dmg, .pkg, installer .zip files)
3. Creating organized folder structure
4. Moving files to appropriate categories

## Folder Structure
Create these folders on Desktop:
- `Screenshots/` - All screenshot files (Screenshot*.png)
- `Documents/` - PDFs, with subfolders:
  - `Tax/` - Tax forms, K-1s, 1099s, W9s
  - `Invoices/` - Invoices and receipts
  - `Resumes/` - Resume versions
- `Media/` - Media files:
  - `Audio/` - .wav, .mp3, .aif, .m4a files
  - `Video/` - .mov, .mp4 files
  - `Screen Recordings/` - Screen Recording*.mov files
- `Design/` - Design assets:
  - `Logos/` - Logo files
  - `SVG/` - Vector graphics
  - `Exports/` - Frame exports, design exports
- `Projects/` - Project-specific folders (by name)
- `Archive/` - Misc files, extracted folders
- `Apps/` - .app bundles

## Rules
- Keep personal archives (music projects, course materials)
- Delete app installers (.dmg, .pkg) after confirming apps are installed
- Ask before deleting any file over 1GB
- Create backup file listing before reorganizing
- Move Downloads contents to Desktop first, handle duplicates

## Steps
1. Create backup listing: `ls -la ~/Desktop > ~/.backup_desktop_$(date +%Y%m%d).txt`
2. Check for and handle duplicates between Desktop and Downloads
3. Move all Downloads to Desktop
4. Delete app installers (DaVinci Resolve, Affinity, etc.)
5. Create folder structure
6. Move files by type/category
7. Report space saved and final organization
