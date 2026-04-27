---
name: Conventional Commits on request
description: Khi user yêu cầu commit, luôn dùng Conventional Commits format
type: feedback
originSessionId: 75eeca58-f5bf-4368-a971-aba0f77f56a3
---
Luôn dùng Conventional Commits khi tạo commit message theo yêu cầu của user.

**Why:** User muốn commit history nhất quán, rõ ràng theo chuẩn Conventional Commits.

**How to apply:** Mỗi khi user yêu cầu `git commit` hoặc `dotfiles commit`, prefix message với type phù hợp: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `perf:`, `style:`, `build:`, `ci:`. Scope optional. Subject ngắn gọn, body giải thích WHY nếu cần.
