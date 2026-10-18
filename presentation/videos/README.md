# INFOSYS 735 Assignment 2 — Four Console recordings

**Recorded by the team on 18 October 2026.** The four videos are stored in a dedicated Cloudflare R2 bucket rather than committing large MP4 files to the Git repository.

| Part | Presenter | Topic | Raw clip | Duration | Resolution | Size |
| --- | --- | --- | --- | ---: | --- | ---: |
| 1 | Vincent | Architecture / CloudFormation | [Watch / download MP4](https://pub-2a01662e7c3b458a9acdb3e022a4b184.r2.dev/assignment2/part1-vincent.mp4) | 1:19 | 1920×1080 | 7.7 MiB |
| 2 | Zack | Networking / VPC / Security | [Watch / download MP4](https://pub-2a01662e7c3b458a9acdb3e022a4b184.r2.dev/assignment2/part2-zack.mp4) | 3:53 | 1920×1080 | 14.0 MiB |
| 3 | Sam | Reliability / ALB / Auto Scaling | [Watch / download MP4](https://pub-2a01662e7c3b458a9acdb3e022a4b184.r2.dev/assignment2/part3-sam.mp4) | 5:06 | 1920×1080 | 21.0 MiB |
| 4 | Kevin | Forecasting / Lambda / Monitoring | [Watch / download MP4](https://pub-2a01662e7c3b458a9acdb3e022a4b184.r2.dev/assignment2/part4-kevin.mp4) | 3:38 | 1920×1080 | 10.9 MiB |

**Total raw footage:** approximately **13:56**, about **53.6 MiB**. All four objects were uploaded successfully and verified to return HTTP 200 with `Content-Type: video/mp4` and byte-range support. The original files remain in `E:\Downloads\` on Sam's Windows PC.

## Video hosting

- Cloudflare R2 bucket: `infosys735-a2-presentations`
- Public URL prefix: `https://pub-2a01662e7c3b458a9acdb3e022a4b184.r2.dev/assignment2/`
- Object keys: `assignment2/part1-vincent.mp4` through `assignment2/part4-kevin.mp4`
- Access: **public (anyone with a link can view)**. Do not upload AWS keys, AWS Academy credentials, private emails or other secrets to this public bucket.
- These are source Console recordings for Zack to edit. **They are not yet a single finished 15-minute pitch video.** The assignment's separate `.txt` recording URL should point to the finished recording once the team edits and uploads it.

## Supporting materials

- [中文录制分镜与逐步操作](../console-recording-guide.zh-CN.md)
- [English four-person presentation script](../presenter-script.md)
- [Console recording cue sheet](../console-recording-cue-sheet.md)
- [Earlier Vincent-only reference recording (stored in Git)](Part1_Vincent_Console.mp4) — older take, separate from the new R2 upload.

### How to download for editing

Open each MP4 link and save the video. Zack can use the four original files as independent clips, add Vincent's PPT, add each speaker's voiceover, and prepare a single final video. The URLs refer to the files as uploaded; they have not been edited together or resynchronized.
