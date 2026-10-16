# Sam's AWS Console recording cue sheet — 15:00 edit map

**中文逐步点击与停留秒数指南：** [console-recording-guide.zh-CN.md](console-recording-guide.zh-CN.md)（优先照中文版手动操作；本文件保留英文成片时间轴）。

**Purpose:** Sam captures four clean, **silent** 2560×1440 source videos on Windows; Zack edits to 1920×1080. Each presenter records their English narration separately with the matching IDs in [presenter-script.md](presenter-script.md). You may capture extra transition time and trim later; the timestamps below are **final cut positions**, not literal wall-clock navigation deadlines.

**Recommended filenames:** `Part1_Vincent_Raw.mp4`, `Part2_Zack_Raw.mp4`, `Part3_Sam_Raw.mp4`, `Part4_Kevin_Raw.mp4`. Store locally in ignored `recordings/` and only share the four final clips with the group.

## Part 1 — Vincent (00:00–03:00)

| Shot | Final cut | Dur. | Screen / click path | Hold | 录屏操作 / 检查点 |
|---|---|---:|---|---:|---|
| 1.1 | 00:00–00:20 | 20s | SLIDE: Title slide — AnyGroupLLC / team | ≥15s | 标题页停留，显示四个组员。不要录 AWS 登录或凭证。 |
| 1.2 | 00:20–00:45 | 25s | SLIDE: Business goals / stakeholder slide | ≥18s | 一页展示 CTO、CISO、IT Manager、CFO 四类需求。 |
| 1.3 | 00:45–01:10 | 25s | SLIDE: Final architecture diagram, INCLUDING S3 → Lambda → S3 | ≥20s | 最终架构图必须包含新 Forecasting；放大中间公网 ALB→两层 ASG→模拟 DB 链路。 |
| 1.4 | 01:10–01:35 | 25s | SLIDE: Production vs Learner Lab / provisional sizing | ≥18s | 突出生产建议 t3.medium / m6i.xlarge / db.m6i.2xlarge；标注 Lab 为 t3.micro dummy。 |
| 1.5 | 01:35–02:00 | 25s | CONSOLE: CloudFormation → Stacks → anygroupllc-a2 → Stack info | ≥12s | 选中 Stack，显示正确 Region us-east-1、状态 CREATE_COMPLETE / UPDATE_COMPLETE；若非完成状态停止拍摄。 |
| 1.6 | 02:00–02:25 | 25s | CONSOLE: CloudFormation → Resources (slow scroll) | ≥15s | 缓慢滚动，停在 VPC/Subnets，再停 ALB/ASG，再停 S3/Lambda/SNS 资源；可分拍。 |
| 1.7 | 02:25–02:45 | 20s | CONSOLE: CloudFormation → Outputs | ≥10s | 展示 VpcId、PublicAlbDns、ForecastBucket，不必复制旧的历史 ALB 地址。 |
| 1.8 | 02:45–03:00 | 15s | SLIDE: GP1 concept → GP2 evidence / handoff | ≥10s | 一页简表：GP1 已提议 vs GP2 新部署、脚本验证、预测流。 |

## Part 2 — Zack (03:00–07:00)

| Shot | Final cut | Dur. | Screen / click path | Hold | 录屏操作 / 检查点 |
|---|---|---:|---|---:|---|
| 2.1 | 03:00–03:30 | 30s | CONSOLE: VPC → Your VPCs → anygroupllc-a2-vpc | ≥14s | 显示 VPC 10.0.0.0/16，区域 us-east-1，查清标签，不要混入其他 VPC。 |
| 2.2 | 03:30–04:00 | 30s | CONSOLE: VPC → Subnets → filter project VPC | ≥18s | 一次尽量显示六个：public-a/b、app-a/b、db-a/b，展开 AZ 列。 |
| 2.3 | 04:00–04:30 | 30s | CONSOLE: VPC → Route tables → public-rt → Routes | ≥15s | 点 Public Route Table，展示 0.0.0.0/0 → Internet Gateway。 |
| 2.4 | 04:30–05:00 | 30s | CONSOLE: VPC → Route tables → app-rt-a and app-rt-b | ≥14s | 先展示 app A 默认路由到 NAT A，再切 app B NAT B；允许剪切跳转。 |
| 2.5 | 05:00–05:30 | 30s | CONSOLE: VPC → Route tables → db-rt-local-only → Routes | ≥17s | 保持路由页至少 15 秒，清楚显示只有 10.0.0.0/16 local，没有 0.0.0.0/0。 |
| 2.6 | 05:30–06:00 | 30s | CONSOLE: VPC → NAT Gateways → nat-a / nat-b | ≥15s | 展示 2 台 NAT 与不同 public subnet / AZ；未 Available 则不要称健康。 |
| 2.7 | 06:00–06:30 | 30s | CONSOLE: EC2 → Security Groups → inbound rules (Public ALB → Frontend → Internal ALB → Backend → DB) | ≥12s | 至少展示 Frontend SG 来源为 Public ALB SG，以及 DB 8080 来源为 Backend SG；其他可快速串场。 |
| 2.8 | 06:30–07:00 | 30s | CONSOLE: VPC → Network ACLs → public-nacl → inbound rules | ≥18s | 显示允许来自 10.0.0.0/16 的 TCP 443、HTTP 80、ephemeral 1024–65535；不要宣称现场验证 NAT HTTPs。 |

## Part 3 — Sam (07:00–11:00)

| Shot | Final cut | Dur. | Screen / click path | Hold | 录屏操作 / 检查点 |
|---|---|---:|---|---:|---|
| 3.1 | 07:00–07:25 | 25s | CONSOLE: EC2 → Load Balancers → public and internal ALBs | ≥14s | 展示两个 ALB 的 Scheme / Type：public internet-facing、internal internal。 |
| 3.2 | 07:25–07:55 | 30s | CONSOLE: EC2 → Target Groups → anygroup-front-tg → Targets | ≥18s | 出现两个 Healthy frontend targets；如果 unhealthy 停止录制并排查。 |
| 3.3 | 07:55–08:25 | 30s | CONSOLE: EC2 → Target Groups → anygroup-back-tg → Targets | ≥18s | 出现两个 Healthy backend targets，显示 Health status 列、AZ 列。 |
| 3.4 | 08:25–08:55 | 30s | CONSOLE: EC2 → Auto Scaling Groups → anygroup-frontend-asg → Details / Instance management | ≥18s | 显示 Desired 2, Min 2, Max 4 和 Instance AZ；必要时滚动。 |
| 3.5 | 08:55–09:25 | 30s | CONSOLE: EC2 → Auto Scaling Groups → anygroup-backend-asg → Details / Instance management | ≥17s | 显示 Backend ASG 2/2/4，两 AZ；不能仅凭 ASG 配置宣称已真实故障切换。 |
| 3.6 | 09:25–09:50 | 25s | CONSOLE: Auto Scaling Group → Automatic scaling → CPU target tracking | ≥15s | 显示 Target Tracking 60% CPU；如愿意切 CloudWatch 再展示 70% alarm，但不必强行同框。 |
| 3.7 | 09:50–10:10 | 20s | CONSOLE: Browser → current PublicAlbDns → / | ≥12s | 新浏览器标签打开 Outputs 提供的 Public ALB DNS，显示 AnyGroupLLC Prototype 首页。 |
| 3.8 | 10:10–10:30 | 20s | CONSOLE: Browser → current PublicAlbDns → /api/ | ≥12s | 地址栏末尾 `/api/`，JSON `service: backend-app-tier` 可见且放大。 |
| 3.9 | 10:30–11:00 | 30s | CONSOLE: Browser → current PublicAlbDns → /api/db/ | ≥17s | 浏览器到 `/api/db/`，显示 JSON `service: dummy-oracle-tier`；不是真实 Oracle。 |

## Part 4 — Kevin (11:00–15:00)

| Shot | Final cut | Dur. | Screen / click path | Hold | 录屏操作 / 检查点 |
|---|---|---:|---|---:|---|
| 4.1 | 11:00–11:20 | 20s | SLIDE: Sales forecast data flow: S3 → Lambda → S3 | ≥15s | 切换成简单业务流程图，标 S3 event, moving average, forecast JSON。 |
| 4.2 | 11:20–11:45 | 25s | CONSOLE: S3 → Bucket from ForecastBucket output → forecast-input/ | ≥14s | 从 CF Outputs 的当前 bucket 名进 S3，展示 bucket 非公开；不要显示敏感凭证。 |
| 4.3 | 11:45–12:20 | 35s | CONSOLE: S3 → forecast-input/ → Upload → upload unique CSV | ≥15s | 使用 sample-sales.csv 的独立命名副本上传；先显示文件和上传 success，再拍 Object key。 |
| 4.4 | 12:20–12:50 | 30s | CONSOLE: Lambda → Functions → anygroup-sales-forecast → Configuration / Triggers | ≥15s | 显示 S3 Trigger prefix `forecast-input/` suffix `.csv`；如果近期失败查看 Monitor Logs。 |
| 4.5 | 12:50–13:20 | 30s | CONSOLE: S3 → forecast-output/runs/<filename>.json → Open / Download | ≥17s | 展示独立 per-input JSON 对象最近修改时间，路径与上传文件名对应。 |
| 4.6 | 13:20–13:50 | 30s | CONSOLE: View JSON → source_key, next_day_sales_forecast, window_size | ≥20s | 停留 JSON 至少 20 秒，展示 source_key、forecast_date、forecast 559.71；测试前确认样例未更改。 |
| 4.7 | 13:50–14:15 | 25s | CONSOLE: CloudWatch → Alarms → anygroup-frontend-high-cpu | ≥14s | 显示 Threshold 70%，Period 300s x 2，alarm action SNS；不要假称已触发过。 |
| 4.8 | 14:15–14:35 | 20s | CONSOLE: SNS → Topics → anygroup-infrastructure-alarms → Subscriptions | ≥12s | 展示 Topic；如订阅 PendingConfirmation 或为空，应坦诚说明没有验证邮件送达。 |
| 4.9 | 14:35–15:00 | 25s | SLIDE: Business value, limitations and recommendation / team credits | ≥18s | 最后一页展示已实施、未验证、下一步计划，片尾四人姓名。 |


## How Sam can launch the Windows recorder (without speaking)

The Windows PC has a **2560×1440** primary display and FFmpeg with `gdigrab` / `libx264` (confirmed 16 October). [record-console.ps1](record-console.ps1) records the primary desktop at **1920×1080, 30fps, video only**, with a **fixed duration that automatically finalizes the MP4**. Its `-DryRun` option has been checked; an actual screen capture has **not** been performed yet.

Run from Windows PowerShell (or have Remote Arc launch the same command after checking that the screen is safe):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "\\wsl.localhost\Ubuntu\home\samyao\work\infosys735-assignment2\presentation\record-console.ps1" -Part 1 -Seconds 300
```

Change `-Part` to `2`, `3`, `4`; suggested raw capture budgets are **5 / 6 / 6 / 6 minutes** to allow transition and retakes. The final edited sections stay **3 / 4 / 4 / 4 minutes**. You can optionally test arguments safely with `-DryRun` first. **Do not end the FFmpeg process early with a force kill** or the MP4 may not finalize; use the fixed-duration auto-stop and trim later. Captures appear in **`recordings/`**, which is Git-ignored.

The screen recorder cannot navigate AWS Console by itself. Browser navigation needs a shared, enabled Chrome tab and permission for Click & fill, or Sam can perform the steps manually while Remote Arc controls the recording process. Never capture AWS Details, `.env`, account tokens, mailbox personal data, or unapproved applications.

## Recorder checklist and editing rules

1. **Before recording:** Deploy only after the owner approves AWS running costs. Run `./check-lab.sh` and `./verify.sh` from the WSL repo; verify actual CloudFormation outputs, target health and fresh S3 forecast, and ensure no AWS Details, session keys, `.env` or console account credentials are on screen. The historical ALB URL in older pitch notes must not be reused.
2. **Desktop:** Use the single 2560×1440 primary Windows display (verified 16 October); capture desktop with FFmpeg at 30fps, scale to 1920×1080, do not record microphone. Chrome at 100–110% zoom, hide notifications and unrelated tabs, use light theme and at least 12–14pt text.
3. **Clip plan:** One silent take per part. Start recording on a neutral AWS Console page, leave a 3-second lead-in, navigate at a comfortable pace, and keep each important successful status page stationary for ≥10–20 seconds. Retake a shot if a page fails to load; Zack can remove navigation gaps and dead time.
4. **Fresh S3 demonstration:** Use a unique copy of `sample-sales.csv`, upload via S3 Console under `forecast-input/`, then open the **corresponding** object under `forecast-output/runs/`. Confirm `source_key` and forecast value. Lambda is asynchronous: wait for new output instead of faking the result.
5. **Evidence:** Capture stack status, resource list, public/internal ALBs, **2 healthy targets** per group, cross-AZ ASGs, `/`, `/api/`, `/api/db/`, VPC routes, NACL TCP 443, S3 event and Lambda result, CloudWatch 300s×2, SNS topic state.
6. **Editing:** Use slides only for business problems, updated full architecture, provisional production sizing, forecasting flow, and final caveats; otherwise stay on real Console. Four distinct speakers should be audible. Do not paste secrets, invent healthy states, imply that a slide is a real Console capture, or fabricate an AWS result.
7. **Afterward:** Inspect four playable source MP4s, audio alignment, and final 15:00 cut; upload only the final video to a stable shared link. Submit slides/PDF plus a separate `.txt` containing the recording URL, and everyone must complete TeamMates evaluations. Delete paid AWS resources after saving evidence and obtaining group approval.

**Practical limitation:** CloudFormation and unit-test validation alone cannot demonstrate the working AWS console. If the stack remains deleted, pause the filming and keep the script as a rehearsal plan rather than presenting simulated footage as a live implementation.
