# Contributing to kwtsms-ruby

Thank you for your interest in contributing to the kwtsms Ruby gem.

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/boxlinknet/kwtsms-ruby.git
   cd kwtsms-ruby
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Run tests:
   ```bash
   bundle exec rake test
   ```

4. Run integration tests (requires API credentials):
   ```bash
   RUBY_USERNAME=your_user RUBY_PASSWORD=your_pass bundle exec rake test_integration
   ```

## Branch Naming

- `feature/description` for new features
- `fix/description` for bug fixes
- `docs/description` for documentation changes

## Pull Request Checklist

- [ ] All existing tests pass (`bundle exec rake test`)
- [ ] New code has tests
- [ ] No external runtime dependencies added
- [ ] Ruby 2.7+ compatibility maintained
- [ ] CHANGELOG.md updated

## Code Style

- Follow standard Ruby conventions (snake_case methods, CamelCase classes)
- Use `frozen_string_literal: true` in all files
- Keep zero external runtime dependencies

## Reporting Issues

Open an issue at https://github.com/boxlinknet/kwtsms-ruby/issues with:
- Ruby version (`ruby -v`)
- Gem version (`KwtSMS::VERSION`)
- Steps to reproduce
- Expected vs actual behavior
