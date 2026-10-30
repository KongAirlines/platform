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
comment with the changed platform files and development and production Gateway
diffs.

The workflows use `kongctl sync` so reviewed desired state reconciles creates,
updates, and deletions. Konnect resources are isolated by the `platform`
namespace, while decK select tags scope Gateway deletion to the aggregate or
shared configuration owned by this repository.

The complete production Gateway aggregate is one reconciliation unit. Every
input file uses `env-prod` as its decK select tag; entity-level ownership tags
remain available to identify the owning team or service. decK merges the input
files and combines their select tags, so different selectors would change the
scope of the entire operation. CI and the production workflow validate this
contract. Preview and synchronize all files listed in
[`konnect/production-gateway.yaml`](konnect/production-gateway.yaml) together.
A single file is only part of this desired state and is not a standalone sync.

Development control planes use a smaller shared reconciliation unit:
[`konnect/development-gateway.yaml`](konnect/development-gateway.yaml) selects
resources tagged with both `env-dev` and `owner-platform`. This includes the
shared anonymous Consumer and global ACE. Service repositories use their own
ownership and select tags for Services, Routes, and service-level plugins.
CI and the foundations workflow validate this boundary before synchronization.

## Shared Portal branding

Both Portals reference the same files in [`konnect/branding/`](konnect/branding/)
using kongctl's `!file` support. Edit `portal.css` for custom styling,
`theme.json` for theme colors, and `assets.json` for the logo and favicon data
URLs. A single change updates development and production through the shared
foundations workflow, with its normal production approval.

The branding is taken from the KongAir public Portal export. Each Portal keeps
its own customization reference and access settings. Navigation, pages, domains,
and authentication are managed separately from the shared branding.

## Portal pages and navigation

Each Portal has a published root page (`/`), a searchable API catalog, an About
page, and a Guides parent with nested getting-started, application-access, and
environment guides. Development pages and snippets are private; production
pages and snippets are public. API publication visibility and registration
approvals remain independent.

Edit the shared Markdown Components content in
[`konnect/portal/pages/`](konnect/portal/pages/), guide sidebar snippets in
[`konnect/portal/snippets/`](konnect/portal/snippets/), and header/footer links
in [`konnect/portal/menu.json`](konnect/portal/menu.json). `foundations.yaml`
declares each Portal's page hierarchy with unique resource references and
environment-specific visibility. Child slugs are relative to their parent,
so `getting-started` under `guides` resolves to `/guides/getting-started`.
Content and navigation edits trigger the approved foundations workflow.

## Production Portal custom domain

The production Portal's `custom_domain` in
[`konnect/foundations.yaml`](konnect/foundations.yaml) declares its public
hostname and uses Konnect-managed TLS with HTTP domain verification. The
approved foundations workflow reconciles this configuration.

The hostname's public DNS CNAME must point to the Portal's generated
`default_domain`. Konnect verifies that DNS configuration and provisions the
certificate. If CAA records restrict certificate issuance, allow `pki.goog`
while preserving issuers required by other services. Allow time for DNS and
certificate provisioning before checking the custom URL.

When moving a hostname between Portals, check its existing custom-domain
assignment and release that assignment if required before provisioning the
new one. Record the previous DNS target before changing the CNAME. See
[Konnect custom domains](https://developer.konghq.com/dev-portal/custom-domains/)
for DNS and certificate requirements.

## Runtime authentication

Flights and Destinations are public and require no credential. Bookings and
Customer Information require an API key from a Dev Portal application with an
approved registration for the API. The platform owns a Key Auth application
strategy per environment, the anonymous Consumer, and global ACE configured
with `match_policy: required` and `anonymous: kongairlines-anonymous`.

Service-owned post-functions run after ACE. They reject its anonymous fallback
and requests without an application ID in ACE's request context. Successful requests
receive `X-KongAir-Account-ID` from that ID, replacing any supplied
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
and unapproved registrations. `KONGAIRLINES_ROTATED_API_KEY` checks that a new
key for the first application preserves its account. A GitHub-hosted runner cannot reach a developer's
localhost; use `scripts/verify-gateway-auth.sh` locally for that case.

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
