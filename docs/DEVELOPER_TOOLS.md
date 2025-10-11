## Developer Tools

### Available Commands

**`npm run lint:check`**  
Checks all files for code quality issues (errors, bugs, style violations).  
Use before committing to see what needs fixing.

**`npm run lint`**  
Automatically fixes ESLint issues where possible.  
Use when `npm run lint:check` shows fixable problems.

**`npm run format`**  
Formats all files with Prettier for consistent style.  
Use before committing to ensure code consistency.

**`npm run setup:hooks`**  
Installs Git hooks that run checks before commits/pushes.  
**Run once** after cloning the repository.

### Quick Start

```bash
# After cloning
npm install
npm run setup:hooks

# Before committing
npm run lint
npm run format
```
