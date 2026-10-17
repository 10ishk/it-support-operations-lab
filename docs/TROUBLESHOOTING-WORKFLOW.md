# Troubleshooting workflow

1. **Identify the problem.** Write the reported symptom, occurrence time and affected operation in the incident template. Distinguish a controlled scenario from a real fault.
2. **Establish scope.** Determine whether one application, one VM, a subnet or multiple users are affected. Record recent changes and environment details without identifiers.
3. **Gather information.** Use the entry point with selected System, Network, Events or Services checks. Preserve timestamps, status details and unavailable checks. Save targeted screenshots.
4. **Form a hypothesis.** State an explanation and the evidence that would support or disprove it. Do not equate a warning with a root cause.
5. **Test the hypothesis.** Use a focused comparison: valid versus nonexistent DNS name, listening versus closed local port, or hashes before/after a controlled content edit. Capture actual results.
6. **Apply the least disruptive fix.** Save original settings and rollback steps. Avoid broad resets and speculative changes. Limit simulation to a disposable VM and data.
7. **Verify functionality.** Repeat the original failed test and affected application operation. Confirm rollback/cleanup. For recovery, compare all original, backup and restored digests and inspect restored content.
8. **Document the resolution.** Fill confirmed cause, actions actually taken, verification, evidence links and follow-up. Keep synthetic examples and hypotheses labeled. Review privacy before staging evidence.
9. **Escalate when appropriate.** Escalate unresolved, recurring, multi-device or managed-infrastructure issues with a concise timeline, sanitized evidence and actions already tried. Do not include credentials or entire raw logs.

The [incident exercises](../incidents/README.md) and [template](../templates/incident-template.md) use this sequence. If a test cannot run, document the limitation and its effect on confidence rather than inferring success.
