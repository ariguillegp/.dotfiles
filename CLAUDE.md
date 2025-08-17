# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains dotfiles and Nix configurations for managing both system-level (NixOS) and user-level (home-manager) configurations on Linux systems. It uses the Nix Flakes feature to define reproducible configurations.

## Common Commands

### Building and Updating

- Update dependencies and rebuild:
  ```bash
  ./update.sh
  ```

- Rebuild configurations without updating dependencies:
  ```bash
  ./rebuild.sh
  ```

- Manually rebuild only the home-manager configuration:
  ```bash
  home-manager switch --impure --flake '.#nixhome'
  ```

- Manually rebuild only the system configuration:
  ```bash
  sudo nixos-rebuild switch --flake '.#nixhome'
  ```

## Repository Structure

- `flake.nix`: The entry point defining inputs and outputs for both NixOS and home-manager configurations
- `hosts/`: Contains configurations for specific machines
  - `nixhome/`: Configuration for the primary system
    - `configuration.nix`: System-level NixOS configuration
    - `hardware-configuration.nix`: Hardware-specific configuration
    - `home.nix`: User-level home-manager configuration
- `modules/`: Modular configurations that can be imported
  - `home-manager/`: Home-manager modules for various tools and applications
    - Individual tool configurations (neovim.nix, git.nix, etc.)
    - `variables.nix`: Central location for variables used across configurations
    - `config/`: Configuration files for specific applications

## Architecture

This repository follows a sophisticated modular approach with several key patterns:

### Core Architectural Patterns

1. **Dual Configuration Architecture**:
   - `nixosConfigurations.nixhome`: System-level NixOS configuration
   - `homeConfigurations.nixhome`: User-level home-manager configuration
   - Both target the same machine but handle different scopes

2. **Centralized Variables Pattern**:
   - `modules/home-manager/variables.nix` serves as single source of truth
   - Contains git identities, SSH keys, project paths, and user information
   - Injected into all modules via `_module.args` for consistency

3. **Multi-Identity Git Configuration**:
   - Conditional includes based on directory structure
   - Personal: `/home/aristides/Projects/personal/*`
   - Projects: `/home/aristides/Projects/cc/*`
   - Each context has separate SSH keys, emails, and GitHub hosts

4. **External Config Integration**:
   - Simple tools: Configuration directly in Nix
   - Complex tools: External files in `config/` directory
   - Pattern: `builtins.readFile` for including external configurations

5. **Stable + Unstable Package Access**:
   - Dual nixpkgs inputs (stable 25.05 + unstable)
   - Access bleeding-edge packages when needed (e.g., `pkgs-unstable.claude-code`)

### Key Components
- **Hyprland**: Wayland compositor with Waybar status bar
- **Fish**: Default shell with custom functions
- **Ghostty**: Primary terminal emulator
- **Neovim**: Primary editor with Lua configurations
- **Cursor**: VS Code-based AI code editor (from unstable packages)
- **Custom Git tools**: `git-clone-worktree` for a better git workflow
- **Identity enforcement**: Pre-commit hooks validate git identity by directory
- **SSH key management**: Automatic SSH key switching based on project context

## Development Patterns

### Variable Injection Pattern
```nix
# In hosts/nixhome/home.nix
_module.args = vars;  # Pass variables to all modules

# In modules (e.g., git.nix)
{ identities, paths, ... }: # Receive variables as arguments
```

### Conditional Configuration Pattern
```nix
# Git identity switching based on directory
includes = [
  {
    condition = "gitdir:${identities.personal.projDir}/**";
    contents = { user.email = "${identities.personal.email}"; };
  }
];
```

### External Config Integration Pattern
```nix
# Reading external Lua files into Neovim config
extraLuaConfig = ''
  ${builtins.readFile ./config/nvim/after/options.lua}
'';
```

## Working with this Repository

### Development Workflow
1. Make changes to relevant module files in `modules/home-manager/`
2. Test changes: `./rebuild.sh` (rebuilds both user and system configs)
3. For dependency updates: `./update.sh` (updates flake.lock, then rebuilds)
4. Commit changes (pre-commit hook validates git identity automatically)

### Important Notes
- **Identity enforcement**: Git identity is validated based on directory context
- **Two-stage rebuild**: User configuration builds first, then system (requires sudo)
- **Module orchestration**: `hosts/nixhome/home.nix` imports all modules and passes variables
- **Custom tools**: Use `git-clone-worktree` or `gcw` fish function for git workflows
- **Pre-commit validation**: Automatic checks for SSH keys, signing keys, and GitHub authentication
- **Directory structure enforcement**: Project directories auto-created with `.gitkeep` files

## Custom Tools and Scripts

### Git Worktree Management
- **`git-clone-worktree`**: Clone repositories in worktree-ready format with bare repo in `.bare/`
- **Usage**: `git clone-worktree <repo-url> [directory-name]`
- **Structure**: Creates `.bare/` directory and `.git` file pointing to it

### Pre-commit Validation (`core-precommit`)
Comprehensive validation script that checks:
- Git identity (email, signing key) matches directory context
- SSH agent is running and accessible
- Required SSH keys are loaded
- GitHub authentication works for the correct host
- Commit signing is properly configured

### Identity Contexts
Based on directory structure, different identities are automatically applied:
- **Personal**: `/home/aristides/Projects/personal/*` and dotfiles
- **Projects (CC)**: `/home/aristides/Projects/cc/*`
- Each context has separate SSH keys, email addresses, and GitHub hosts
