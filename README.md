# KongAirlines Platform Team

This repository is the Platform Team half of the
[Konnect Reference Platform](https://developer.konghq.com/konnect-reference-platform/).
It contains only shared Konnect foundations, access assignments, and the
governed aggregate production Gateway state. Service teams manage their own
Catalog APIs and development Gateway configuration in their service
repositories.

## Ownership

The Platform Team owns:

- the `customer-data` and `flight-data` organization teams;
- the `customer-data-dev`, `flight-data-dev`, and `kongairlines-prod` control
  planes;
- the development and production Developer Portals;
- separate development and production Key Auth application auth strategies;
- system-account team membership and role assignments; and
- review and application of the aggregate production Gateway configuration.

The Platform Team does not copy OpenAPI specifications or manage service-owned
Catalog APIs. There is no Reference Platform registry and no central polling
workflow.

## Desired state

- [`konnect/foundations.yaml`](konnect/foundations.yaml) declares shared teams,
  control planes, portals, and application auth strategies.
- [`konnect/access.yaml`](konnect/access.yaml) assigns roles to existing
  repository-specific system accounts. Account creation, token issuance, and
  GitHub secret placement remain manual bootstrap steps.
- [`konnect/production-gateway.yaml`](konnect/production-gateway.yaml) resolves
  the production control plane and applies all four reviewed decK files in one
  kongctl `_deck` operation.
- [`gateway/prod/`](gateway/prod/) contains exact service-repository artifacts.
  Do not edit these files here; make the change in the owning service and
  promote it again.

All v1 workflows use `kongctl apply`. Omitted resources are not deleted.

## Production promotion

Each service repository generates and reviews its production candidate, then a
trusted workflow opens or updates a PR here. The PR records the source
repository, commit, checksum, and pinned tool versions. Merging a platform PR
applies the combined Gateway state to `kongairlines-prod`. The service team then
manually applies its production Catalog manifest from that same source commit
through a protected GitHub Environment.

The kongctl manifests intentionally exercise generalized external lookup and
control-plane API implementation behavior. The latter depends on
[Kong/kongctl#1992](https://github.com/Kong/kongctl/pull/1992).

## Security

See [Security](SECURITY.md) for information on reporting vulnerabilities.
