# KongAirlines Platform Team

This repository is the Platform Team half of the
[Konnect Reference Platform](https://developer.konghq.com/konnect-reference-platform/).
It contains only shared Konnect foundations, access assignments, and the
governed aggregate production Gateway state. Service teams manage their own
Catalog APIs and development Gateway configuration in their service
repositories.

## Ownership

The Platform Team manages organization-wide governance and shared runtime
infrastructure. This includes teams and RBAC, control planes, Developer Portal
resources, application authentication strategies, shared control-plane
plugins, and the review and application of production Gateway configuration.

## Desired state

Start in [`konnect/`](konnect/) for the Platform Team's Konnect desired state
and [`gateway/prod/`](gateway/prod/) for reviewed production Gateway artifacts.
The workflows in [`.github/workflows/`](.github/workflows/) validate and synchronize
that configuration. Successful PR validation maintains a reviewer-facing
comment with the changed platform files and production Gateway diff.

The workflows use `kongctl sync` so reviewed desired state reconciles creates,
updates, and deletions. Konnect resources are isolated by the `platform`
namespace, while decK select tags scope Gateway deletion to the aggregate or
shared configuration owned by this repository.

## Production promotion

Each service first reviews a release PR that retains the stable OpenAPI
contract, selects it for production, advances the root development beta, and
commits the materialized production candidate. After that PR merges, a trusted
workflow copies the exact reviewed candidate into a PR here without
regenerating it. The PR records the source repository, commit, checksum, and
pinned tool versions. Merging a platform PR synchronizes the combined Gateway
state to `kongairlines-prod`. The service team then manually synchronizes its
production Catalog manifest from that same source commit through a protected
GitHub Environment.

The deployment workflows intentionally install the latest stable kongctl
release. This keeps the example exercising current supported declarative
behavior and makes compatibility regressions visible.

## Security

See [Security](SECURITY.md) for information on reporting vulnerabilities.
