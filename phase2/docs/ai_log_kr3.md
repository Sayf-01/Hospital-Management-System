# KR-3 AI assistance log

Date: November 16, 2026
Contributor: Krish Patel
Tool: ChatGPT with Python and Git tooling
Scope: KR-3 preparation; code and validation assistance.
Status: prepared for Krish's review and execution; no GitHub push or PR created.

## Prompt summary

Krish requested starting KR-3 because the full data was needed by teammates,
and asked for a check of their GitHub branches before proceeding.

The earlier KR-1/KR-2 conversation requested fictional hospital sources, clean
linked records, controlled problems and four source-format writers. Those
artifacts were reused unchanged; this entry does not replace their earlier AI
disclosure.

## Work assisted

- Inspected live GitHub branch and pull-request status.
- Read Krish's KR-3 guide and the repository's actual maps and writer.
- Ran the full writer with seed 363.
- Read back and reconciled source counts using the existing LA-1 loader.
- Tested the existing SA-3 cleaner in an isolated checkout.
- Wrote a freeze/verification script and a freeze runbook.
- Identified the need to preserve raw bytes against Git line-ending conversion.

## Checks performed

- All four source totals satisfy 5,500–9,500 records each.
- Total raw entity instances: 30,091, including two malformed lines.
- All 60 source/entity counts match the loader plus its malformed log.
- Full regeneration produces identical sources, count report and answer key.
- All 1,035 generator log entries have applied status.
- Conservative planted-risk exposure including affected descendants is below
  5% for each source.
- Existing SA-3 cleaner counts reconcile; final SQL validation remains outstanding.

Krish must review these files, run the commands on Windows, inspect the outputs,
and include the actual commands and results in the team's final report. Do not
claim checks ran on Krish's computer until his output confirms them.
