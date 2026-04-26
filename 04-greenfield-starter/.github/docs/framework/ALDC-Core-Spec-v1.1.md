# ALDC Core Specification v1.1

## Status

This workspace expects a local copy of the ALDC Core specification at this path because toolkit metadata and repository documentation reference it directly.

## Purpose

This document acts as the local normative entry point for the AL Development Collection configuration used in this repository.

Use it when you need to understand:

- the ALDC core version configured by the workspace;
- the relationship between agents, skills, workflows, and instructions;
- the expected toolkit structure under `.github/`;
- how `aldc.yaml` references the toolkit specification.

## Canonical Upstream Source

The published upstream specification is available here:

- [ALDC Core Spec v1.1](https://github.com/javiarmesto/AL-Development-Collection-for-GitHub-Copilot/blob/main/docs/framework/ALDC-Core-Spec-v1.1.md)

## Local Repository Notes

- `aldc.yaml` uses this file as `core.specFile`.
- Repository documentation may link here as the local normative specification.
- If the workspace is updated from a newer ALDC release, this file should be refreshed or replaced with the corresponding version.

## Recommended Maintenance Rule

When changing `core.version` or `core.specFile` in `aldc.yaml`, keep this file path valid. Do not leave `specFile` pointing to a missing local document.
