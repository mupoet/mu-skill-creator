# Contributing to mu-skill-creator

Thanks for your interest in contributing! This project provides a quality framework for AI agent skill creation, and we welcome improvements from the community.

## How to Contribute

### Reporting Bugs

Open a [Bug Report](https://github.com/mupoet/mu-skill-creator/issues/new?template=bug_report.md) with steps to reproduce, expected vs. actual behavior, and your environment details.

### Suggesting Features

Open a [Feature Request](https://github.com/mupoet/mu-skill-creator/issues/new?template=feature_request.md) describing the problem you'd like to solve and your proposed approach.

### Submitting Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-improvement`)
3. Make your changes
4. Run the audit script: `bash scripts/skill-audit.sh mu-skill-creator`
5. Ensure SKILL.md stays ≤ 300 lines
6. Commit and push to your fork
7. Open a Pull Request against `main`

### What We Look For

- **Consistency**: Changes should be reflected across SKILL.md, references/, and scripts/ where applicable
- **No sensitive info**: No credentials, internal URLs, or employee identifiers
- **Audit passes**: `skill-audit.sh` should report no errors after your changes
- **Clear motivation**: Explain *why* the change matters, not just *what* changed

## Code of Conduct

Be respectful, constructive, and inclusive. We're building tools to help people write better AI agent skills — let's keep the community welcoming for everyone.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
