---
name: project_js_toolchain
description: "JS/TS toolchain của user — runtime, package manager, version manager"
metadata: 
  node_type: memory
  type: project
  originSessionId: 349dfc4d-ebba-4946-a888-1d431c93b660
---

User dùng **Bun** (cài qua Homebrew `oven-sh/bun/bun`) làm package manager và runtime mặc định cho JS/TS.

- `bun install` thay `npm install` cho project mới
- `bun run <script>` thay `npm run`
- `bun <file.ts>` chạy TypeScript trực tiếp không cần build step
- **Giữ `fnm`** cho project cần Node.js version cụ thể (`.nvmrc`, CI/CD)

**Why:** Bun nhanh hơn npm 10–100x, native TS, built-in test runner — phù hợp indie hacker ưu tiên tốc độ.

**How to apply:** Khi suggest lệnh cài deps hoặc chạy script JS/TS, dùng `bun` thay `npm`/`npx`. Vẫn dùng `fnm` nếu project chỉ định Node version cụ thể.
