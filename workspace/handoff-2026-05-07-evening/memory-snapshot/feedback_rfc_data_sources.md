---
name: RFC drafting must ingest provided grep / data as primary source
description: When PRESIDENT or boss1 supplies grep output, file paths, or audit data in a task brief, treat it as the primary source for RFC §-by-§ enumeration; self-run grep is a cross-check only.
type: feedback
originSessionId: 2e406483-749c-411a-aa75-3d7d93acad19
---
When drafting an RFC / design doc in response to a task that includes pre-supplied data (grep results, file paths, audit lists), ingest the provided data as the primary source. Self-run grep is a cross-check, not a replacement. Diff your own findings against the supplied data and reconcile any deltas before submitting.

**Why:** On 2026-04-28 (Track 2 widget inject_X RFC), worker3 drafted §4 from a self-run grep and missed VStack/HStack/Padding `inject_engine` overrides at `src/widget/layout.rs:247/502/612` — those exact lines had been provided in the prior PRESIDENT message but weren't cross-referenced. The miss undercounted "removable handwritten forwards" by 3, requiring a §9.9 re-precision pass after PRESIDENT pushed back. Result was correct in the end but cost a round-trip.

**How to apply:** Before submitting any RFC / design doc, scan the task brief and any boss1/PRESIDENT messages for inline `grep` output, line refs (`file:NNN`), or "see this list" enumerations. Mark each item as ingested. If your own search returns a smaller set, treat that as a red flag and reconcile.
