# 25-minute demo guide

## Message

> The AI can write the code, but it should not invent the business behaviour.

## Timing

| Time | Activity |
| ---: | --- |
| 0-2 min | Introduce the business case |
| 2-5 min | Show the original requirement and ask what is missing |
| 5-8 min | Show the optimized requirement |
| 8-13 min | Run `al-spec.create` |
| 13-16 min | Review and approve the specification |
| 16-22 min | Run the AL Implementation Specialist |
| 22-24 min | Compile or inspect objects and tests |
| 24-25 min | Close with Vibe Coding vs ALDC |

## Preparation

1. Open this folder as the VS Code workspace root.
2. Install the AL Language, GitHub Copilot and ALDC extensions.
3. Run `AL Collection: Install Toolkit to Workspace`.
4. Download symbols for the target BC 27 sandbox.
5. Keep a previously generated specification available as backup.

## Live flow

1. Open `requirements/original-requirement.md`.
2. Discuss `requirements/review-notes.md`.
3. Open `requirements/optimized-requirement.md`.
4. Execute `prompts/01-create-spec.md`.
5. Review only classification, objects, validation and tests.
6. Execute `prompts/03-implement.md`.
7. Compile and inspect the resulting AL objects.

## Closing

Ask: "Who thinks Copilot wrote the code?"

Then answer:

> That is not the important part. The important part is that Copilot did not decide the behaviour.

We do not use AI to replace functional analysis. We use it to automate the implementation of approved functional analysis.
