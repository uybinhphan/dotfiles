# Global CLAUDE.md

Hướng dẫn cá nhân áp dụng cho mọi phiên Claude Code của user `uybinh`.
Áp dụng song song với CLAUDE.md cấp project (project file ưu tiên hơn nếu xung đột).

## Profile

- **Vai trò**: Indie hacker / solo builder — ưu tiên tốc độ, ship được, tránh quy trình rườm rà.
- **Stack chính**: TypeScript/JavaScript, Python, Rust.
- **Lĩnh vực**: scripts & dotfiles, AI/LLM apps (Claude API), backend/API, web frontend.

## Phong cách giao tiếp

- **Ngôn ngữ**: trả lời theo ngôn ngữ user dùng trong câu hỏi (tiếng Việt → tiếng Việt, English → English).
- **Độ dài**: ngắn gọn vừa phải. Kèm 1–2 câu lý do hoặc trade-off khi quyết định không hiển nhiên. Không lan man, không lặp lại diff.
- **Khi không chắc**: nói thẳng "không chắc" + đề xuất cách verify, đừng đoán.

## Mức độ tự chủ

- **Hỏi trước khi làm** với task không hiển nhiên: xác nhận hướng tiếp cận trước, rồi thực thi từng bước.
- Vẫn được tự do với thao tác local, đảo ngược được (đọc file, chạy test, sửa nháp).
- **Bắt buộc xác nhận trước** với: xoá file/branch, đổi shared state, install/uninstall package.

## Quy ước code

- **Không over-engineer**: YAGNI. Không thêm abstraction, error handling, fallback cho tình huống chưa xảy ra. Ba dòng lặp tốt hơn một abstraction non.
- **Không comment thừa**: chỉ comment khi WHY không hiển nhiên (ràng buộc ẩn, workaround cho bug cụ thể, hành vi gây bất ngờ). Không mô tả WHAT.
- **Sửa root cause**: không workaround, không `--no-verify`, không bypass hook. Hook fail → fix nguyên nhân.
- **Branch mới cho feature**: không commit trực tiếp lên `main`/`master`. Tạo nhánh mới khi bắt đầu việc mới.

## Git workflow

- **Commit theo Conventional Commits**: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `perf:`, `style:`, `build:`, `ci:`. Scope optional: `feat(auth): ...`. Message subject ngắn, mô tả WHY ở body nếu cần.

## Môi trường

- **Máy**: macOS, Zsh + Starship prompt.
- **Dotfiles**: quản lý qua bare repo. Dùng alias `dotfiles` thay `git` cho mọi file trong `$HOME`:
  ```
  dotfiles status / add / commit / push
  ```
  Không dùng `git` thường để thao tác file dotfiles.
- **Packages macOS**: Homebrew là source of truth. App/CLI mới → đề xuất thêm vào `~/.config/dotfiles/Brewfile`.
- **Node/JS/TS**: `bun` là runtime và package manager mặc định (`bun install`, `bun run`, `bun <file.ts>`). Giữ `fnm` để quản lý Node.js version cho project yêu cầu Node cụ thể.
- **Python**: `uv` (không pip/poetry trực tiếp trừ khi project yêu cầu).
- **File listing**: `eza` đã alias `ls`/`ll`/`la`/`lt`.

## Claude API / Anthropic SDK

Khi build app dùng Claude API:
- **Model mặc định cho lên kế hoạch / reasoning nặng**: Opus 4.7 (`claude-opus-4-7`).
- **Model mặc định cho triển khai task / production**: Sonnet 4.6 (`claude-sonnet-4-6`).
- **Haiku 4.5** (`claude-haiku-4-5`) cho task đơn giản, latency-sensitive.
- Luôn bật **prompt caching** cho prompts lặp lại (system prompt dài, tool definitions, few-shot).
- Khi user nói "model mạnh nhất" / "model nhanh nhất" → dùng Opus 4.7 / Haiku 4.5 tương ứng.

## Khi xung đột với project CLAUDE.md

Project-level CLAUDE.md ưu tiên hơn file này. Nếu project nói khác (ví dụ commit style khác, không Conventional Commits), theo project.
