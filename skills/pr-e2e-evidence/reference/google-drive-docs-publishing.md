# Google Drive Evidence Publishing

Read this reference when audited evidence must be archived in Google Drive. Use the `audit-doc-sync` skill for Google Docs response synchronization, Drive-backed links and images, native tables, suggestion ownership, and persistence auditing.

## Archive before presentation

1. Choose the access boundary before uploading: named reviewers, organization-with-link, or public-with-link. Prefer Viewer access.
2. Create one root folder and revision-specific subfolders that name the environment and short SHA.
3. Prefer uploading each complete audited package directory when Drive's folder picker and the browser bridge support it. Preserve filenames, nested measurement directories, manifests, and hashes. Otherwise upload one explicit batch per revision and reconcile the resulting inventory against the local package.
4. Keep environments separate. A staging package never becomes production evidence because it shares a Drive folder or Doc.
5. Verify the root permission and one child file's inherited permission. Drive permissions and the Google Doc's sharing state are independent; inspect both.

**Complete when:** every intended package has an exact local-to-Drive file count, revision identity, and verified Viewer boundary.

## Prepare durable review evidence

- Keep videos, JSON, manifests, and mapped screenshots under the revision that produced them.
- Provide descriptive filenames and labels rather than exposing local paths.
- Preserve revision and environment in the surrounding prose; a durable link does not broaden the artifact's claim.
- Keep raw or superseded artifacts in the archive when useful, but link only the mapped review set.

**Complete when:** the archive is recipient-accessible, inventory-checked, and ready for its selected publication surface.
