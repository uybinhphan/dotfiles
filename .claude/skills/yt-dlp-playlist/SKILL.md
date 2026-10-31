---
name: yt-dlp-playlist
description: >
  Tải YouTube playlist bằng yt-dlp. Dùng skill này khi user:
  - Đưa URL YouTube playlist và muốn download (có hoặc không nói rõ "download"/"tải")
  - Nói "download playlist này", "tải playlist youtube", "tải video list", "yt-dlp playlist"
  - Hỏi cách tải nhiều video từ YouTube cùng lúc
  - Đưa link YouTube và hỏi "có tải hết được không" hoặc tương tự
  - Nói chung về việc tải nội dung từ YouTube với yt-dlp
  Trigger cả khi có URL YouTube lẫn câu lệnh liên quan tới tải playlist/video.
---

# yt-dlp Playlist Download

## Mục đích

Hướng dẫn và thực hiện download YouTube playlist bằng yt-dlp với chế độ **interactive** — hỏi user các option trước khi chạy download.

## Luồng xử lý

### 1. Nhận input từ user

User cung cấp URL playlist YouTube. Nếu user chưa có URL, hỏi trước.

### 2. Hỏi các option download (interactive)

Dùng `AskUserQuestion` (single-select) để hỏi lần lượt các option sau. Chỉ hỏi nếu user chưa nói rõ trong câu hỏi.

#### a) Phạm vi tải
- Toàn bộ playlist
- Một khoảng video cụ thể (ví dụ: 1-5, 10-20)
- Một vài video cụ thể (ví dụ: 1,3,5,7)

#### b) Chất lượng video
- Best (mặc định, khuyên dùng)
- 1080p
- 720p
- 480p
- Audio only (mp3) — dùng `--extract-audio --audio-format mp3`

#### c) Định dạng (nếu không phải audio only)
- mp4 (mặc định)
- mkv

#### d) Rate limiting
- Không giới hạn
- Nhẹ (nghỉ 5s giữa các video)
- Trung bình (nghỉ 10s + giới hạn tốc độ 5M)

#### e) Archive tracking
Hỏi user có muốn dùng file archive để lần sau chạy chỉ tải video mới không:
- Có (dùng `--download-archive archive.txt`)
- Không

### 3. Build command & preview

Sau khi thu thập đủ option, hiển thị câu lệnh yt-dlp sắp chạy:

```bash
yt-dlp \
  --download-archive archive.txt \
  --sleep-interval 5 \
  --limit-rate 5M \
  -f "bestvideo[ext=mp4][height<=1080][vcodec^=avc1]+bestaudio[ext=m4a]/best[ext=mp4][height<=1080]" \
  --merge-output-format mp4 \
  "URL_PLAYLIST"
```

Hỏi user xác nhận trước khi chạy (`[y/N]`).

### 4. Chạy download

Dùng Bash tool để chạy lệnh yt-dlp. Monitoring nếu cần (playlist lớn).

## Các option mapping

Dưới đây là mapping từ lựa chọn của user sang flag yt-dlp:

```yaml
phạm_vi:
  toàn_bộ: ""
  khoảng: "--playlist-items {start}-{end}"
  cụ_thể: "--playlist-items {list}"

chất_lượng:
  # macOS: thêm [vcodec^=avc1] + [ext=mp4/m4a] để ưu tiên h264, tránh VP9 không mở được native
  best: "-f 'bestvideo[ext=mp4][vcodec^=avc1]+bestaudio[ext=m4a]/best[ext=mp4]'"
  1080p: "-f 'bestvideo[ext=mp4][height<=1080][vcodec^=avc1]+bestaudio[ext=m4a]/best[ext=mp4][height<=1080]'"
  720p: "-f 'bestvideo[ext=mp4][height<=720][vcodec^=avc1]+bestaudio[ext=m4a]/best[ext=mp4][height<=720]'"
  480p: "-f 'bestvideo[ext=mp4][height<=480][vcodec^=avc1]+bestaudio[ext=m4a]/best[ext=mp4][height<=480]'"
  audio: "--extract-audio --audio-format mp3"

định_dạng:
  mp4: '--merge-output-format mp4'
  mkv: '--merge-output-format mkv'

rate_limit:
  không: ""
  nhẹ: "--sleep-interval 5"
  trung_bình: "--sleep-interval 10 --limit-rate 5M"

archive:
  có: "--download-archive archive.txt"
  không: ""

thư_mục:
  mặc_định: "-o '%(title)s.%(ext)s'"
  thư_mục_con: "-o '%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s'"
```

Luôn dùng `--yes-playlist` và `--no-overwrites` để tránh lỗi. Luôn dùng `--no-mtime` (giữ nguyên thời gian download, tránh nhầm lẫn).

## Output directory

- Mặc định: download vào thư mục hiện tại, mỗi video là file riêng
- Có thể tạo thư mục con theo tên playlist: `-o '%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s'`
- Hỏi user nếu không chắc, suggest tạo thư mục con cho playlist dài

## Edge cases

- **Video private/deleted**: yt-dlp sẽ skip và báo lỗi, tiếp tục video tiếp theo (vì có `--yes-playlist` và `--ignore-errors` mặc định)
- **Age-restricted**: cần `--cookies-from-browser` hoặc đăng nhập. Hỏi user nếu gặp lỗi này
- **Playlist rỗng**: báo cho user biết
- **Mất mạng giữa chừng**: yt-dlp hỗ trợ resume, chạy lại lệnh tương tự là tiếp tục
- **File trùng tên**: `--no-overwrites` + `--no-mtime` xử lý
