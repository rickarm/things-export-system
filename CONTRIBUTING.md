# Contributing to Things Daily Export System

Thank you for your interest in contributing! This project helps Things users export their data for AI-driven analysis and insights.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- **Clear title**: Describe the problem concisely
- **Environment**: macOS version, Things3 version
- **Steps to reproduce**: What did you do?
- **Expected vs actual behavior**: What should have happened?
- **Logs**: Include relevant error logs from `~/kb/ThingsSnapshot/export.error.log`

### Suggesting Enhancements

We welcome feature requests! Please open an issue with:
- **Use case**: Why would this be useful?
- **Proposed solution**: How should it work?
- **Alternatives considered**: What other approaches did you think about?

### Pull Requests

1. **Fork the repository** and create a new branch
2. **Make your changes** following the code style below
3. **Test your changes** thoroughly:
   - Run the installer script
   - Verify exports work correctly
   - Check JSON is valid with `jq`
4. **Update documentation** if needed (README, QUICK_REFERENCE, etc.)
5. **Submit a pull request** with:
   - Clear description of changes
   - Reference to related issue (if any)
   - Test results

## Code Style

### AppleScript
- Use tabs for indentation (matching the existing code)
- Add comments for complex logic
- Use helper functions for reusable code
- Include error handling for file operations

### Shell Scripts
- Use bash best practices
- Quote variables to handle spaces
- Add error checking (`set -e`)
- Include user-friendly output messages

### Documentation
- Use clear, concise language
- Include code examples
- Test all commands before documenting

## Development Setup

1. Clone your fork:
```bash
git clone https://github.com/YOUR_USERNAME/things-export-system.git
cd things-export-system
```

2. Test the installation:
```bash
./install.sh
```

3. Make changes and test:
```bash
osascript ~/Scripts/export_things_daily_snapshot.scpt
jq . ~/kb/ThingsSnapshot/$(date +%Y-%m-%d)_things_snapshot.json
```

## Areas for Contribution

We'd especially welcome contributions in these areas:

- **Export formats**: CSV, different JSON structures, etc.
- **Configuration options**: User-configurable settings
- **AI analysis examples**: Example prompts and use cases
- **Documentation**: Tutorials, videos, blog posts
- **Testing**: Edge case handling, error scenarios
- **Localization**: Support for different languages

## Questions?

Feel free to open an issue with the "question" label if you're unsure about anything!

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
