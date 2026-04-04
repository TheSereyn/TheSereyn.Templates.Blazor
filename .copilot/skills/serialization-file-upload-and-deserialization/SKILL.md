---
name: "serialization-file-upload-and-deserialization"
description: "Secure deserialization, XML parser configuration, file upload trust boundaries, archive extraction safety, and path traversal in .NET."
domain: "security"
confidence: "high"
source: "manual — authored from canonical references"
---

## Context

Deserializing attacker-controlled data with a polymorphic deserializer is a Critical risk — it can lead to remote code execution. File upload endpoints and archive extraction introduce path traversal and arbitrary file execution risks. XML parsers with DTD processing enabled can be exploited for XXE attacks. These attack surfaces share a common theme: trusting external data to dictate internal behaviour.

## Best used for

APIs with file upload, import/export flows, archive extraction, XML processing services.

## Primary references

- GitHub Docs — C# queries for CodeQL: https://docs.github.com/en/code-security/reference/code-scanning/codeql/codeql-queries/csharp-built-in-queries
- OWASP Secure Code Review Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Secure_Code_Review_Cheat_Sheet.html

## Patterns

### Safe deserialization

**System.Text.Json:** does not support polymorphic type loading from external type names by default — safe. The `[JsonPolymorphic]` attribute uses discriminator values, not arbitrary type names.

**Newtonsoft.Json — safe configuration:**

```csharp
var settings = new JsonSerializerSettings
{
    TypeNameHandling = TypeNameHandling.None
};
var obj = JsonConvert.DeserializeObject<MyDto>(json, settings);
```

**Safe alternatives to BinaryFormatter:** `System.Text.Json`, `Newtonsoft.Json` (with `TypeNameHandling.None`), `MessagePack` (without untyped objects).

### XML parser — XXE prevention

```csharp
// SAFE in .NET 4.5.2+ — DTD processing disabled by default
var reader = XmlReader.Create(stream);

// SAFE explicit configuration
var settings = new XmlReaderSettings
{
    DtdProcessing = DtdProcessing.Prohibit,
    XmlResolver = null
};
var reader = XmlReader.Create(stream, settings);
```

### Archive extraction — zip slip prevention

```csharp
foreach (var entry in archive.Entries)
{
    var destPath = Path.GetFullPath(Path.Combine(destDir, entry.FullName));
    if (!destPath.StartsWith(Path.GetFullPath(destDir) + Path.DirectorySeparatorChar))
        throw new InvalidOperationException("Zip slip detected");
    entry.ExtractToFile(destPath);
}
```

**Key check:** after `Path.GetFullPath()`, does the resolved path start with the intended destination directory? If not, reject the entry.

### File upload trust boundary

- Validate file content (magic bytes / file signatures) in addition to extension.
- Dangerous extensions to block: `.exe`, `.dll`, `.sh`, `.bat`, `.ps1`, `.aspx`, `.cshtml`.
- Store uploads outside the web root (not in `wwwroot`) to prevent direct execution.
- Rename uploaded files on storage — never use the original filename as the storage key.
- Set `Content-Disposition: attachment` on download responses to prevent browser execution.
- Scan with antivirus if feasible; at minimum, restrict upload size.

### Path handling

- `Path.Combine` does not prevent path traversal — if a segment starts with `/` (any platform) or `\` (Windows), it replaces the preceding path.
- Correct traversal check: `Path.GetFullPath(resolved).StartsWith(Path.GetFullPath(allowedRoot))`.
- Encode paths before using in URLs; decode before filesystem operations.
- Reject null bytes in file paths (some older systems terminate at null byte).

## Anti-Patterns

### BinaryFormatter — banned

```csharp
// CRITICAL — disabled in .NET 8 (throws NotSupportedException); fully removed in .NET 9
var formatter = new BinaryFormatter();
var obj = formatter.Deserialize(stream);
```

Any use is Critical — migrate to a safe alternative immediately.

### Newtonsoft.Json TypeNameHandling enabled

```csharp
// CRITICAL — allows attacker to instantiate arbitrary types
var settings = new JsonSerializerSettings
{
    TypeNameHandling = TypeNameHandling.All  // or Auto, Objects
};
var obj = JsonConvert.DeserializeObject(untrustedJson, settings);
```

### XML parser with DTD processing enabled

```csharp
// UNSAFE — explicitly enables DTD/external entities
var settings = new XmlReaderSettings
{
    DtdProcessing = DtdProcessing.Parse,
    XmlResolver = new XmlUrlResolver()
};
```

Also flag: `XmlDocument.Load()` or `XPathDocument` without explicit `XmlResolver = null` in older code paths.

### Zip extraction without path validation

```csharp
// VULNERABLE — entry.FullName can contain "../" sequences
foreach (var entry in archive.Entries)
{
    entry.ExtractToFile(Path.Combine(destDir, entry.FullName));
}
```

### Trusting file extensions

- File extensions are attacker-controlled — never trust them for security decisions.
- Using the original filename as the storage key.
- Storing uploads inside `wwwroot` or any web-accessible directory.

## Examples

**Safe Newtonsoft.Json deserialization:**

```csharp
var settings = new JsonSerializerSettings
{
    TypeNameHandling = TypeNameHandling.None
};
var dto = JsonConvert.DeserializeObject<OrderDto>(json, settings);
```

**Safe XML parsing:**

```csharp
var settings = new XmlReaderSettings
{
    DtdProcessing = DtdProcessing.Prohibit,
    XmlResolver = null
};
using var reader = XmlReader.Create(inputStream, settings);
```

**Safe archive extraction:**

```csharp
var destRoot = Path.GetFullPath(destinationDirectory);
foreach (var entry in archive.Entries)
{
    var destPath = Path.GetFullPath(Path.Combine(destRoot, entry.FullName));
    if (!destPath.StartsWith(destRoot + Path.DirectorySeparatorChar))
        throw new InvalidOperationException("Zip slip detected");
    Directory.CreateDirectory(Path.GetDirectoryName(destPath)!);
    entry.ExtractToFile(destPath, overwrite: false);
}
```

**Safe file upload handling:**

```csharp
var allowedExtensions = new HashSet<string> { ".jpg", ".png", ".pdf" };
var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
if (!allowedExtensions.Contains(ext))
    return Results.BadRequest("File type not allowed");

var storageName = $"{Guid.NewGuid()}{ext}";
var storagePath = Path.Combine(_uploadRoot, storageName); // _uploadRoot is outside wwwroot
await using var stream = File.Create(storagePath);
await file.CopyToAsync(stream);
```

## Review cues

- `BinaryFormatter` — Critical; must be removed.
- `TypeNameHandling` != `None` — Critical deserialization risk.
- `DtdProcessing.Parse` or `new XmlUrlResolver()` — XXE risk.
- `ExtractToFile(` without `StartsWith` check — zip slip.
- `Path.Combine(` with user-supplied segments without `GetFullPath` + `StartsWith` validation — path traversal.
- File saved to `wwwroot` — direct execution risk.
- Original filename used as storage key — path traversal and collision risk.
- Missing `Content-Disposition: attachment` on file download endpoints.

## Good looks like

- No use of `BinaryFormatter` anywhere in the codebase.
- `TypeNameHandling` is explicitly set to `None` or omitted (default is `None`).
- XML parsers have `DtdProcessing = DtdProcessing.Prohibit` and `XmlResolver = null`.
- Archive extraction validates every entry path with `GetFullPath` + `StartsWith`.
- Uploaded files are renamed, stored outside the web root, and validated by content type.
- Download endpoints set `Content-Disposition: attachment`.
- `Path.Combine` results are validated against an allowed root before any filesystem operation.

## Common findings / likely remediations

| Finding | Severity | Remediation |
|---------|----------|-------------|
| `BinaryFormatter` usage | Critical | Replace with `System.Text.Json` or safe alternative |
| `TypeNameHandling.All` / `Auto` / `Objects` | Critical | Set `TypeNameHandling = TypeNameHandling.None` |
| `DtdProcessing.Parse` with `XmlUrlResolver` | High | Set `DtdProcessing = DtdProcessing.Prohibit`, `XmlResolver = null` |
| Zip extraction without path validation | High | Add `GetFullPath` + `StartsWith` check before extracting |
| Uploads stored in `wwwroot` | High | Move upload storage outside the web root |
| Original filename used as storage key | Medium | Rename to GUID or hash-based name on storage |
| Missing `Content-Disposition: attachment` | Medium | Add header to file download responses |
| `Path.Combine` with unvalidated user input | High | Validate resolved path starts with allowed root |
| No file size limit on upload | Medium | Enforce max size via `[RequestSizeLimit]` or middleware |
