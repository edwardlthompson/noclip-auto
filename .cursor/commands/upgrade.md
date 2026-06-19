# Template upgrade check

Compare upstream [agent-project-bootstrap](https://github.com/edwardlthompson/agent-project-bootstrap) with this repo:

1. Read `.template-version` and `.template-update.json`.
2. Review @docs/BOOTSTRAP_TEMPLATE_MAP.md for drift.
3. Run `.\scripts\validate-bootstrap.ps1 -Quick`.
4. Cherry-pick missing template artifacts per gap analysis; bump `.template-version` only after gates pass.
5. Log major merges in @DECISION_LOG.md.

Begin now.
