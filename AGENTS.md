# Repository Guidelines

## Repo Essentials

This repo is for building AWS lambda functions with tsc and deploying with terraform/open-tofu. This repo MUST have the following essential files and folders:

- docker/Dockerfile
- docker/build.sh
- .env-template
- tf_main.tf
- tf_variables.tf
- tf_outputs.tf
- src/index.ts
- package.json
- tsconfig.json
- \_docker
- \_tf
- AGENTS.md

All other scripts and files are on a per-project basis.

## Security

- Never read or write to .env file
- Never read or write files outside of this repo without my persmission

## File Structure

- See [here](https://github.com/d-w-d/sbn-lambda-S3-write-template) for template repo structure

## Technical Design Guidelines

- Typescript

  - Use TypeScript with strict typing whenever possible.
  - Prefer organizing shared utilities under `src/lib`.
  - Place TypeScript interfaces in dedicated files within the `src/models` directory.
  - Prefix interface names with `I` (e.g., `IWordPressData`).
  - Prefix boolean variables with `is` (e.g., `isLoaded`).
  - Avoid introducing new runtime dependencies without updating the project plan in `README.md`.

- Functional Programming Paradigm

  - Generally prefer to move logic and data out of entry scripts and into dedicated files within `src/lib`.
  - Generally prefer functional programming patterns:
    - Always name functions in `camelCase`.
    - Prefer pure functions that avoid side effects.
    - Prefer to place a single exported function inside a file of the same name placed within `/src/lib/`; if this file needs helper functions that are not used elsewhere, and if they are relatively short and simple, then place them in the same file.
    - Make the names of the functions highly descriptive to clarify their purpose.
    - Prefer immutability (e.g., using `map`, `filter`, `reduce`, and the spread operator) over mutability (e.g., `for` loops, `push`, `pop`, etc.).
    - Add a JSDoc comment for each function, describing its purpose; inputs and outputs are not needed.

- env vars

  - Use environment variables for configuration settings that may change between deployments or environments.
  - Document all environment variables in `README.md` and `.env-template`.

- Operational BASH Scripts

  - Operate this repo with bash scripts in the root dir, prefixed with '\_' and with no suffix (e.g., `_docker`)

  - Whenever you update a script, run `shellcheck [script]` to ensure compliance with best practices.

- Docker

  - We build all lambdas within an AWS container to ensure compatibility. All docker-related files should be placed in the `./docker` directory.

- Terraform / Open-Tofu

  - All `.tf` files should be placed in the root directory and prefixed `tf_`.
  - For simplicity sake, we do NOT use modules
  - Always use a `tf_variables.tf` file to define all variables; many will be passed by sourcing `.env`

- Lambda Configuration

  - We aim to be thorough in specifying the bahevior of the lambda function and its environment; build terraform files and workflows around the detailed contents of `.env-template`; all of these env vars need to be passed through terraform to the lambda function.
  - Make logs to CloudWatch using a dedicated logger function with JSON formatting.

## Documentation

- Keep `README.md` up to date with architectural decisions, environment variables, and integration plans.
- Document any new environment variables in both `README.md` and `.env-template`.

## Testing

- When tests or linters are added, document how to run them in `README.md`.
