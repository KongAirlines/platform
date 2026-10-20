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

Flights and Destinations are public and require no credential. Bookings and
Customer Information require an API key from a Dev Portal application with an
approved registration for the API. The platform owns a Key Auth application
strategy per environment, the anonymous Consumer, and global ACE configured
with `match_policy: required` and `anonymous: kongairlines-anonymous`.

Service-owned post-functions run after ACE. They reject its anonymous fallback
and requests without a resolved application principal. Successful requests
receive `X-KongAir-Account-ID` from the principal ID, replacing any supplied
account header and removing the legacy passenger header and API key upstream.
Each application gets an isolated synthetic customer and bookings account;
this is application authorization, not passenger login.

Developers sign up, create an application, request access, and generate API
keys through Dev Portal. Developer and application approvals remain manual.
A public documentation page does not grant runtime access. API keys are
runtime secrets and never belong in manifests or PRs.

The manual **Verify Gateway authentication** workflow accepts a reachable
proxy URL and uses `KONGAIRLINES_TEST_API_KEY` from the selected GitHub
Environment. Optional `KONGAIRLINES_SECOND_API_KEY` and
`KONGAIRLINES_UNREGISTERED_API_KEY` extend verification to account isolation
and unapproved registrations. A GitHub-hosted runner cannot reach a developer's
localhost; use `scripts/verify-gateway-auth.sh` locally for that case.

The legacy JWT Consumers remain only during the rolling migration so existing
Gateway artifacts continue to function until both service promotions finish.
Remove their manifests and `KONGAIRLINES_JWT_PRIVATE_KEY` environment secrets
after that rollout. No new JWT credential provisioning is required.

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
