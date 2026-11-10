# Agentic Programming

The resources here include:

- [Presentations](/resources/presentations/): slides with best practices for organized agentic programming.
- [Plan template](/resources/plan-template.md): a basic plan blueprint.
- [Skill template](/resources/skill-template.md): a basic skill blueprint for documenting a reusable
  agent workflow.

- [cabin](cabin): This folder is an **example** of how I organize a software development project
with agentic programming.
I use the example of building a modern Norwegian mountain cabin, detailed in the [presentation](resources/presentations/Agentisk%20programmering%20p%C3%A5%20et%20tokensbudsjett.pptx), to illustrate this project organization. The cabin example is
organized as follows:
  - [/cabin/.agents/](cabin/.agents/): reusable skills for building the cabin.
  - [/cabin/plans/](cabin/plans/): plans for cabin construction.
  - [/cabin/docs/](cabin/docs/): cabin specifications and requirements.
  - [/cabin/AGENTS.md](cabin/AGENTS.md): instructions for agents working on the cabin.
  - [/cabin/README.md](cabin/README.md): instructions for humans working on the cabin.

The cabin example is maintained as part of this repository, not as a separate Git repository or submodule.

The [.devcontainer](.devcontainer) folder contains files to open the repo inside a Development Container ran by WSLc. See [Devcontainer Examples](https://github.com/NorskRegnesentral/devcontainer_examples) for examples and guidelines about how we use devcs in SAND.