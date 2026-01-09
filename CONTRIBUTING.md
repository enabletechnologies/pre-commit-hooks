# Contributing to ENABLE

We would love for you to contribute to ENABLE and help make it even better than it is today!
As a contributor, here are the guidelines we would like you to follow:

## Code of Conduct

Help us keep ENABLE open and inclusive.
Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## Got a Question or Problem?

We recommend using google chat or mail to ask support-related questions.

## Found a Bug?

If you find a bug in the source code, you can help us by submitting an issue to our GitHub Repository.

## Missing a Feature?

You can _request_ a new feature by submitting an issue to our GitHub Repository.
If you would like to _implement_ a new feature, please consider the size of the change in order to determine the right steps to proceed:

- For a **Major Feature**, first open an issue and outline your proposal so that it can be discussed.
  This process allows us to better coordinate our efforts, prevent duplication of work, and help you to craft the change so that it is successfully accepted into the project.

  **Note**: Adding a new topic to the documentation, or significantly re-writing a topic, counts as a major feature.

- **Small Features** can be crafted and directly submitted as a Pull Request.

## Submission Guidelines

### Submitting an Issue

Before you submit an issue, please search the issue tracker. An issue for your problem might already exist and the discussion might inform you of workarounds readily available.

We want to fix all the issues as soon as possible, but before fixing a bug, we need to reproduce and confirm it.
In order to reproduce bugs, we require that you provide a minimal reproduction.
Having a minimal reproducible scenario gives us a wealth of important information without going back and forth to you with additional questions.

A minimal reproduction allows us to quickly confirm a bug (or point out a coding problem) as well as confirm that we are fixing the right problem.

We require a minimal reproduction to save maintainers' time and ultimately be able to fix more bugs.
Often, developers find coding problems themselves while preparing a minimal reproduction.
We understand that sometimes it might be hard to extract essential bits of code from a larger codebase, but we really need to isolate the problem before we can fix it.

Unfortunately, we are not able to investigate / fix bugs without a minimal reproduction, so if we don't hear back from you, we are going to close an issue that doesn't have enough info to be reproduced.

### Change Management Process

Following section covers the change management process for different types of issues/requests and actions to be performed by different stake-holders.

#### A new bug

- For reporter,

1. Select template for `Bug Report` while creating an issue
2. Enter the short title for the bug
3. Enter the detailed description for the bug
   - minimal steps/samples to reproduce the bug in order to save developers time
   - screenshots for the reference
   - environment URL and sample data for the reference
   - expected behavior
   - [optional] relevant log output if available
4. Select the impacted version of the software
5. Assign the bug to the concerned developer
6. Select the expected milestone for the release of the bug fix
7. Review the fix once the status changes to `Ready`
8. Enter the review comments in comments section
9. Close or re-open the bug based on the review of the fix

- For developer,

1. Analyze the bug and the evidences submitted in the bug report
2. Select appropriate `sprint`, `Estimate` for the work involved to fix the bug
3. Move the status to `In Progress` indicating fix in progress
4. Validate the fix for the bug and the expected behavior in local environment
5. Commit the code fix following commit guidelines around commit message
6. Validate the fix for the bug and the expected behavior in development environment
7. Capture additional comments if any in the comments section for the reporter to review
8. Mark the status to `Ready`, once the fix is deployed in QA environment

#### A new feature or a task

- For a new feature enhancement

#### A new python or ui library

- To add a new python/ui library

## Coding Rules

To ensure consistency throughout the source code, keep these rules in mind as you are working:

- All features or bug fixes **must be tested** by one or more specs (unit-tests).
- All public API methods **must be documented**.

  - We follow language specific style guides, but wrap all code at **140 characters**.

    Internally we use a collection of formatting and linting tools. We recommend the same tools to be installed on your workspace, see [tooling](docs/internal/tooling.md).

## Commit Message Format

_This specification is inspired by [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#specification)._

We have very precise rules over how our Git commit messages must be formatted.
This format leads to **easier to read commit history**.

Each commit message consists of a **header**, a **body**, and a **footer**.

```
<header>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

The `header` is mandatory and must conform to the [Commit Message Header](#commit-message-header) format.

The `body` is optional but can be added for providing additional contextual information about the code changes.
When the body is present it must be at least 40 characters long and must conform to the [Commit Message Body](#commit-message-body) format.

The `footer` is optional. The [Commit Message Footer](#commit-message-footer) format describes what the footer is used for and the structure it must have.

#### Commit Message Header

```
<type>(<scope>): <short summary>
  │       │             │
  │       │             └─> Succinct description about changes. Not capitalized. No period at the end.
  │       │
  │       └─> Commit Scope: {module-name}|{component-name}|{document-name}
  │
  └─> Commit Type: build|ci|docs|feat|fix|perf|refactor|test
```

The `<type>` and `<summary>` fields are mandatory, the `(<scope>)` field is optional.

##### Type

Must be one of the following:

- **build**: Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
- **ci**: Changes to our CI configuration files and scripts (examples: CircleCi, SauceLabs)
- **docs**: Documentation only changes
- **feat**: A new feature
- **fix**: A bug fix
- **perf**: A code change that improves performance
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **test**: Adding missing tests or correcting existing tests
- **bump**: release new version

##### Scope

The scope should be the name of the module, component in the module or documentation affected (as perceived by the person reading the changelog generated from commit messages).

_Use package prefixes when a repository contains more than one projects or packages. e.g. in common use `proxy:` for changes to proxy, `cache:` for changes to cache, etc._

##### Summary

Use the summary field to provide a succinct description of the change:

- don't capitalize the first letter
- no dot (.) at the end
- must be at least 40 characters (or 5 words) long
- use past tense (e.g. added, fixed, etc) or third-person simple present (e.g. adds, fixes, etc)

#### Commit Message Body

Just as in the summary, use the imperative, present tense: "fix" not "fixed" nor "fixes".

Explain the motivation for the change in the commit message body. This commit message should explain _why_ you are making the change.
You can include a comparison of the previous behavior with the new behavior in order to illustrate the impact of the change.

#### Commit Message Footer

The footer can contain information about breaking changes and deprecations and is also the place to reference GitHub issues, Jira tickets, and other PRs that this commit closes or is related to.
For example:

```
BREAKING CHANGE: <breaking change summary>
<BLANK LINE>
<breaking change description + migration instructions>
<BLANK LINE>
<BLANK LINE>
Fixes #<issue number>
```

or

```
DEPRECATED: <what is deprecated>
<BLANK LINE>
<deprecation description + recommended update path>
<BLANK LINE>
<BLANK LINE>
Closes #<pr number>
```

Breaking Change section should start with the phrase "BREAKING CHANGE: " followed by a summary of the breaking change, a blank line, and a detailed description of the breaking change that also includes migration instructions.

Similarly, a Deprecation section should start with "DEPRECATED: " followed by a short description of what is deprecated, a blank line, and a detailed description of the deprecation that also mentions the recommended update path.

### Revert commits

If the commit reverts a previous commit, it should begin with `revert: `, followed by the header of the reverted commit.

The content of the commit message body should contain:

- information about the SHA of the commit being reverted in the following format: `This reverts commit <SHA>`,
- a clear description of the reason for reverting the commit message.
