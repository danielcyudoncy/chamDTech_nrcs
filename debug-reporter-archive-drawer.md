# Debug Session: reporter-archive-drawer

- Status: OPEN
- Symptom: `RenderFlex children have non-zero flex but incoming height constraints are unbounded` after tapping `Archive` from the reporter drawer and then reopening the drawer to go back to the dashboard.
- Scope: Reporter mobile flow, archive navigation, drawer navigation, reporter dashboard rendering.
- Hypotheses:
  - Reporter drawer is not the remaining source; another `Column` with flex still exists in the reporter flow.
  - `MyStoriesTab` or a reporter content widget is being mounted inside a sliver/unbounded-height parent and contains an `Expanded`.
  - Returning from archive leaves `_selectedIndex` or route state inconsistent, so the wrong content tree is rendered.
  - A mobile-only reporter widget uses `Expanded`/`Spacer` under shrink-wrap constraints after the archive transition.
  - The failure occurs during state transition, so runtime logs are needed to identify the exact rendered branch.
- Evidence Log:
  - Pending instrumentation.
- Next Step:
  - Inspect the reporter archive/dashboard render path and add minimal instrumentation as the first code change to the existing codebase.
