---
title: Application access
description: Request access and use a Portal-issued application API key.
page-layout:
  sidebar-left: guides-navigation
  sidebar-right: guides-sections
---

::page-section
# Application access

## Register as a developer

Sign up through this Portal and complete any email verification. A Portal
administrator must approve your developer account. Development Portal access
may also require a Portal team assignment.

## Create an application and request access

After approval, sign in and create an application in **My Apps**. Use the
KongAirlines API Key authentication strategy for this Portal's environment.
Request registration for **Bookings**, **Customer Information**, or both,
depending on your integration. An administrator must approve the requested
API registrations; signing in or creating an application is not sufficient.

You do not need an application or API key to call Flights or Destinations.

## Generate a credential

Open your application's Authentication section and generate an API key. Store
it in your local secret store. Never commit it, include it in a URL, paste it
into an issue, or share it in a screenshot.

Send the key in the `X-API-Key` request header. Use HTTPS whenever requests
leave your machine. For example, after securely setting your local variables:

```bash
curl --fail-with-body "${GATEWAY_URL}/bookings" \
  --header "X-API-Key: ${KONGAIR_API_KEY}"
```

## Understand application identity

The key identifies an application, not a passenger. The Gateway uses Dev
Portal application registration to decide whether that application may call
the protected API. It does not provide passenger login or end-user consent.

The example service source demonstrates application-scoped fictional accounts.
Do not send an account or passenger identity header to select another user's
data. Gateway-managed identity headers are not client credentials.

## Troubleshoot access

- Confirm the developer and API registrations are approved.
- Confirm the key belongs to this Portal's environment and the selected API.
- Send the exact `X-API-Key` header; a JWT is not a substitute for this strategy.
- Allow time for registration changes to reach the Gateway.
- Distinguish Gateway authorization errors from upstream service responses.

Rotate credentials through the same application when needed. Revoke exposed
keys promptly; never solve a credential problem by publishing the key.
::
