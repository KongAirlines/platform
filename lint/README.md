# Native configuration policy

Run from repository root with latest stable kongctl, decK 1.65.2 and Python 3:

```sh
python3 scripts/test-lint-policies.py
bash scripts/lint-manifests.sh
```

kongctl checks raw foundation declarations: platform-owned Key Auth strategies
and Portal approval settings. decK checks each original Gateway file, including
its reconciliation selector, shared ACE anonymous fallback and service-owned
plugin boundaries. Source files are checked before rendering because rendering
removes `_info.select_tags`. Policy files and inheritance are local and versioned.
No Konnect credentials are needed.

Keep `deck file validate`, both Ruby deletion-scope guards (including their
trusted pre-sync calls), artifact provenance/checksums, Portal asset/content
validators and runtime tests. They cover relationships, aggregate ownership,
files and behavior that raw lint alone cannot establish. In particular, do not
replace the independent deployment guards until native equivalents have proven
coverage and https://github.com/Kong/kongctl/issues/2653 is resolved.

JSON fixtures are valid YAML inputs exercised by both native engines; negative
cases assert the intended rule diagnostic. kongctl does not expand `!file` or
resolve lookups in lint (issue #2584); Portal content remains separately checked.
