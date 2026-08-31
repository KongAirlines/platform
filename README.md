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
resources, application authentication strategies, and the review and
application of production Gateway configuration.

## Desired state

Start in [`konnect/`](konnect/) for the Platform Team's Konnect desired state
and [`gateway/prod/`](gateway/prod/) for reviewed production Gateway artifacts.
The workflows in [`.github/workflows/`](.github/workflows/) validate and apply
that configuration.

All v1 workflows use `kongctl apply`. Omitted resources are not deleted.

## Production promotion

Each service repository generates and reviews its production candidate, then a
trusted workflow opens or updates a PR here. The PR records the source
repository, commit, checksum, and pinned tool versions. Merging a platform PR
applies the combined Gateway state to `kongairlines-prod`. The service team then
manually applies its production Catalog manifest from that same source commit
through a protected GitHub Environment.

The kongctl manifests use generalized external lookup and control-plane API
implementations. Use kongctl 1.14.0 or later when applying them.

## Security

See [Security](SECURITY.md) for information on reporting vulnerabilities.
