# Setup Guide

This guide explains how to publish lua-z3 to GitHub and the vcpkg registry.

## 1. Create GitHub Repository

First, create a new GitHub repository:

```bash
# Using GitHub CLI (if installed)
gh repo create alexames/lua-z3 --public --description "Lua 5.4 bindings for the Z3 theorem prover" --source=. --push

# Or manually:
# 1. Create repo at https://github.com/new
# 2. Add remote and push:
git remote add origin git@github.com:alexames/lua-z3.git
git push -u origin main
```

## 2. Create a Release Tag

```bash
git tag v0.1.0
git push origin v0.1.0
```

## 3. Add to vcpkg Registry

Navigate to your vcpkg registry and use vcpkger.py:

```bash
cd C:\Users\Alexa\Programming\vcpkg-registry

# Get the latest commit hash from lua-z3
$COMMIT_HASH = git -C "C:\Users\Alexa\Programming\lua-z3" rev-parse HEAD

python vcpkger.py create lua-z3 `
  --github-repo 'alexames/lua-z3' `
  --commit-hash $COMMIT_HASH `
  --version '0.1.0' `
  --port-version 0 `
  --github-token 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 `
  --branch main `
  --description 'Lua 5.4 bindings for the Z3 theorem prover'
```

## 4. Push Registry Changes

```bash
cd C:\Users\Alexa\Programming\vcpkg-registry
git push origin master
```

## 5. Using in Other Projects

Add to your project's `vcpkg.json`:

```json
{
  "dependencies": ["lua-z3"]
}
```

Add to your project's `vcpkg-configuration.json`:

```json
{
  "registries": [
    {
      "kind": "git",
      "baseline": "<get from vcpkger.py output>",
      "repository": "https://github.com/alexames/vcpkg-registry",
      "packages": ["lua-z3", "luawrapper", "targets"]
    }
  ]
}
```

## Updating the Port

When you make changes to lua-z3:

1. Push changes to GitHub
2. Update the port:

```bash
cd C:\Users\Alexa\Programming\vcpkg-registry

python vcpkger.py update lua-z3 `
  --github-repo 'alexames/lua-z3' `
  --commit-hash <new-commit-hash> `
  --version '<new-version>' `
  --port-version 0 `
  --github-token <token> `
  --branch main
```
