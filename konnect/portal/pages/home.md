---
title: Welcome to KongAir
description: Build the next air travel experience with KongAir APIs.
---

::page-hero
---
title-font-size: "clamp(36px, 5vw, 64px)"
title-line-height: "1.2"
description-font-size: "20px"
padding: "64px 24px"
styles: |
  background: linear-gradient(135deg, #effafa 0%, #dcecf8 60%, #ffffff 100%);
  color: #022841;
---
#title
Your next journey starts with an API

#description
Discover destinations, explore flights, and build booking experiences with KongAir.

#actions
  ::k-button{size="large" to="/apis"}
  Explore APIs
  ::
  ::k-button{size="large" appearance="secondary" to="/guides/getting-started"}
  Start building
  ::
::

::page-section
## Explore. Connect. Build.

Start with **Flights** and **Destinations** to discover the public API surface.
For **Bookings** and **Customer Information**, register an application and
request API access through this Portal.

| Your goal | Where to start |
| --- | --- |
| Find API operations and contracts | [API catalog](/apis) |
| Make your first integration | [Getting started](/guides/getting-started) |
| Request a key for protected APIs | [Application access](/guides/application-access) |
| Understand development and production | [Environments and versions](/guides/environments) |
::

::page-section
## Find your API

The catalog shows APIs available to you in this Portal.

::apis-list
---
enable-search: true
persist-page-number: true
---
::
::
