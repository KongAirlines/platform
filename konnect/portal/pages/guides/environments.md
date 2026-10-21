---
title: Environments and versions
description: Keep development and production contracts and credentials separate.
page-layout:
  sidebar-left: guides-navigation
  sidebar-right: guides-sections
---

::page-section
# Environments and versions

## Development

The Development Portal contains pre-production Catalog APIs. Its content and
APIs are private and access depends on developer approval and Portal RBAC.
Service teams manage development Gateway configuration in their team control
planes. Development contracts can change as teams iterate.

## Production

The Production Portal publishes the promoted API contracts. Platform engineers
review production Gateway candidates before deployment to the shared production
control plane. Public documentation does not grant access to protected operations.

## Keep credentials separate

Development and production use separate application authentication strategies.
Create the appropriate application and API registrations in each Portal;
do not assume that a development key works in production.

## Check the API version

Always read the version shown on the selected API contract. Service repositories
keep their current development specification at the root and retain released
contracts as versioned files. A reviewed release promotes the chosen production
contract; merging a development change does not automatically release it.

This reference implementation uses separate Catalog API entities for development
and production. The environment guidance here describes that implemented model,
not a dependency on prerelease Konnect features.
::
