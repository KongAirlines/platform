---
title: Getting started
description: Discover your API and prepare your first request.
page-layout:
  sidebar-left: guides-navigation
  sidebar-right: guides-sections
---

::page-section
# Getting started

## 1. Choose an API

Open the [API catalog](/apis) and select the API you want to use. Read its
OpenAPI contract for paths, parameters, request bodies, and response schemas.

| API | Gateway access |
| --- | --- |
| Flights | Public; no API key or application registration required |
| Destinations | Public; no API key or application registration required |
| Bookings | Approved application registration and valid API key required |
| Customer Information | Approved application registration and valid API key required |

Portal sign-in controls documentation access; it does not automatically grant
runtime access to a protected API.

## 2. Confirm your environment

Check whether you are in the Development or Production Portal. Use the Gateway
proxy URL for that environment, supplied by the platform operator. Do not use
the Portal website URL as the Gateway URL.

Read [Environments and versions](/guides/environments) before moving an integration
between environments.

## 3. Prepare a request

For a public API, no credential is needed. With your Gateway URL set locally:

```bash
curl --fail-with-body "${GATEWAY_URL}/flights"
```

For a protected API, follow [Application access](/guides/application-access)
first. Review the selected contract before sending a request. Gateway
authorization and the response returned by an upstream service are distinct:
a service error does not by itself mean your application key was rejected.
::
