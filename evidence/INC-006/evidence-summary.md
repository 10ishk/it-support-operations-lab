# INC-006 execution evidence

Captured: 2026-10-17.

Outcome: **Completed controlled listener failure; recovery and cleanup verified**.

The local TCP test failed after the loopback listener on dynamically selected port 59845 was stopped.

Native TCP succeeded again. A bounded probe after final cleanup failed, confirming the listener was released.

Cleanup: Listener stopped in finally; CleanupVerified=true. This port is the observed ephemeral value, not a fixed production port.

[Commands](commands.txt) · [Structured observations](observations.json) · [Sanitized output](sanitized-output.txt) · [Incident report](../../incidents/INC-006-tcp-port-connectivity.md)

These are selected actual records, not a raw transcript. Identifiers, network addresses, unrelated messages and personal paths are omitted. Reproduction may yield different counts, timings, ports or digests. Backup content is not published.
