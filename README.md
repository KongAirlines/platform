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
resources, shared Gateway authentication identities, shared control-plane
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

## Runtime authentication

Flights and Destinations are public APIs and require no runtime credential.
Bookings and Customer Information enable the JWT plugin on their Gateway
Services. The Platform Team declaratively owns the shared Consumers and RS256
verification credentials; private signing keys never enter Gateway state or
the repository. A valid token's `iss` claim selects a Consumer, and Kong
Gateway replaces `X-Consumer-Username` with the authenticated Consumer name
before proxying to the service. Tokens used by the verification workflow also
carry `exp`, which the service-owned JWT policies require.

ACE remains a global, `required` policy so only operations represented by APIs
published from the Catalog are routable. None of these API publications select
a Dev Portal application authentication strategy: ACE performs operation
enforcement, JWT protects Bookings and Customer Information, and the two public
APIs remain credential-free.

The manual **Verify Gateway authentication** workflow exercises public access,
missing and invalid JWT rejection, valid identity selection, and forged
`X-Consumer-Username` replacement against a running data plane. Its selected
GitHub Environment must provide `KONGAIRLINES_JWT_PRIVATE_KEY`; the workflow
generates a one-hour token without printing or persisting it.

## Production promotion

Each service first reviews a release PR that retains the stable OpenAPI
contract, selects it for production, advances the root development beta, and
commits the materialized production candidate. After that PR merges, a trusted
workflow copies the exact reviewed candidate into a PR here without
regenerating it. The PR records the source repository, commit, checksum, and
pinned tool versions. Merging a platform PR synchronizes the combined Gateway
state to `kongairlines-prod`. After that succeeds, the platform workflow reads
the changed provenance and dispatches the owning service's production Catalog
workflow with the exact source commit. The service-owned workflow still uses
its own Konnect identity and protected GitHub Environment.

The deployment workflows intentionally install the latest stable kongctl
release. This keeps the example exercising current supported declarative
behavior and makes compatibility regressions visible.

## Security

See [Security](SECURITY.md) for information on reporting vulnerabilities.
