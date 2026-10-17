# Diagnostic reports

Generated runs belong here and are ignored by Git. Each run uses a unique timestamped directory. JSON is the structured source; TXT and local HTML provide readable views. CSV files contain event and service records when those checks run.

No workstation evidence ships with this repository. Review and sanitize every artifact before copying selected evidence into a dedicated incident folder. Use `git add -f <reviewed-file>` only after review. Ignored files are still visible on disk and are not encrypted.

The [sample](sample/README.md) folder describes the output contract without inventing machine results.
