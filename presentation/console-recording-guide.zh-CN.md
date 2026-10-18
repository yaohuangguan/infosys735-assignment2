# INFOSYS 735 Assignment 2｜四人 AWS Console 录制分镜（中文操作版）

> **适用仓库：** `yaohuangguan/infosys735-assignment2` · **区域：** `us-east-1` · **项目 Stack：** `anygroupllc-a2`。
>
> **录制分工（群内最终决定）：** Vincent 负责 Part 1，Zack 负责 Part 2，Sam 负责 Part 3，Kevin 负责 Part 4；Sam 提供真实 Console 画面，四个人各自准备英文讲解/配音，Zack 剪辑成片。
>
> **本文件是手动录屏操作指南，不会自动操作 AWS、启动录屏或部署资源。** 已经录好的旧 Part 1 保留在 [`videos/Part1_Vincent_Console.mp4`](videos/Part1_Vincent_Console.mp4)，本指南不会覆盖它。英文讲稿见 [`presenter-script.md`](presenter-script.md)。

## 一、先记住：按什么标准录

**最终成片 15 分钟，其中 Console 画面约 12 分 25 秒，PPT/开头/结尾约 2 分 35 秒。** 下面给的是 Zack 剪辑时需要的 **成片镜头长度**，不是要求你必须在几十秒内点击完页面。你实际录制可以多留 3–8 秒，切页加载等待可以全部剪掉。

| Part | 讲解成员 | 正式展示范围 | Console 成片目标 | 你录制时建议多留 |
| --- | --- | --- | ---: | ---: |
| 1 | Vincent | 架构、CloudFormation Stack/Resources/Outputs | **1:10（70 秒）** | 原始约 1:30–2:00 |
| 2 | Zack | VPC、Subnets、Routing、NAT、Security | **4:00（240 秒）** | 原始约 5:00–6:00 |
| 3 | Sam | ALB、Target Group、ASG、实际三层请求链路 | **4:00（240 秒）** | 原始约 5:00–6:00 |
| 4 | Kevin | S3→Lambda→预测、CloudWatch、SNS | **3:15（195 秒）** | 原始约 4:30–6:00 |
| — | 组员 PPT | 商业背景、总体架构图、生产规格、结尾 | **2:35（155 秒）** | PPT 由组员另行处理 |

录屏动作遵循这个节奏：

1. **先点击，再等加载完成；完全加载后才开始算“停留秒数”。** 鼠标不要从一处瞬移到另一处，正常拖动约 **0.5–1.0 秒**，靠近目标时略微放慢。
2. 鼠标指向要解释的文字或字段，停 1–2 秒；点击后稍停，再把鼠标移到空白处。**不要反复乱晃**，也不要遮住 Healthy、Status、CIDR 和 Forecast JSON。
3. 对核心证据（Healthy、CREATE_COMPLETE、路由、预测 JSON）**保持静止 12–20 秒**。次要入口页面保持 8–12 秒即可。
4. 切换控制台服务可以慢慢点，也可以暂停录制、打开下一页再继续录。**优先录“每个镜头一条短片”，不是必须一镜到底。** Zack 最后统一剪辑。
5. 录制源至少 **1080p，建议 30 fps，无现场麦克风**（各人后期配音）；Chrome 可以全屏，但要确保**标签栏、地址栏、任务栏、AWS 账号信息/邮箱**不进入最终录制区域。先录 8 秒小样看裁切效果；隐藏通知。
6. 不拍 AWS Academy 的 **AWS Details / AWS CLI**、真实 `.env`、Token、Access Key 或任何个人邮件。AWS Console 页面可能显示账号 ID、资源 ARN：仓库为**公开仓库**，上传前要检查这些是否符合小组的公开范围。
7. 只说画面真实证明的事：**Stack 完成 ≠ 服务健康；Healthy Targets ≠ 已完成灾备故障演练；Dummy DB ≠ Oracle RDS；SNS Topic 存在 ≠ 已发送邮件。**

### 开录之前 2 分钟准备

- AWS Academy → Learner Lab：确保 Lab 仍然启动，注意剩余 **$50 预算**；停止录制后再安排清理资源，避免 NAT Gateway、ALB、EC2 持续计费。
- AWS Console 右上角 Region 切到 **US East (N. Virginia) / `us-east-1`**。
- CloudFormation → Stacks → 找到 `anygroupllc-a2`，必须看到 `CREATE_COMPLETE` 或 `UPDATE_COMPLETE`。不要选择 AWS Academy 自带的教学初始化 Stack。
- 项目的 `verify.sh` 曾经检查通过，但**录制时资源可能发生变化**，仍要自己看页面上的实时状态；AWS Lab 会过期，不能仅靠旧截图。
- 按下方四个 Part 分别录制，推荐文件名：`Part1_Vincent_Raw.mp4`、`Part2_Zack_Raw.mp4`、`Part3_Sam_Raw.mp4`、`Part4_Kevin_Raw.mp4`。

---

## 二、Part 1 — Vincent：Architecture & Solution Improvement

**最终影片位置：01:35–02:45 · Console 共 70 秒。** Vincent 自己负责开场 PPT、业务需求、最终架构图和老师反馈，不需要你录那部分。只拍下面三条。

| 编号 / 成片位置 | 点击操作（严格顺序） | 加载完成后停留 | 必须看到的证据 |
| --- | --- | ---: | --- |
| **1.5 / 01:35–02:00（25 秒）** | AWS Console 搜索框输入 **CloudFormation** → 进入服务 → 左边 **Stacks** → 在列表点击蓝色的 **`anygroupllc-a2`** → 在详情里点 **Stack info** | **15 秒** | 标题 `anygroupllc-a2`，状态 `CREATE_COMPLETE` 或 `UPDATE_COMPLETE`，Description。 |
| **1.6 / 02:00–02:25（25 秒）** | 保持 Stack 详情 → 上方 **Resources** → 如果右侧分栏过窄，点列表栏的折叠箭头扩大资源表 → 看资源数量、Logical ID、Type 和 Status → **缓慢滚动**或点下一页，再停住 | **第一页 10 秒、第二页 10 秒**（中间 5 秒切换） | 实际创建的资源和多个 `CREATE_COMPLETE`；上次共 **68** 项，按当前实时数量为准。能看到 VPC / ALB / ASG / Lambda / S3 中的任意代表资源更好。 |
| **1.7 / 02:25–02:45（20 秒）** | 同一 Stack 详情 → 上方 **Outputs** → 将页面置于 `VpcId`、`PublicAlbDns`、`ForecastBucket` 等输出可读的位置，必要时少量滚动 | **15 秒** | Outputs 的真实部署值；特别是当前 **PublicAlbDns** 和 **ForecastBucket**。不要使用旧 DNS。 |

**交给 Vincent 的解释重点：** GP1 设计里的 Multi-AZ、ALB、ASG 是原有架构提议；GP2 的新价值是把它们变成**真实 CloudFormation 资源和可验证的原型**，并新增 S3/Lambda Forecasting。老师关于实例规格的反馈已经体现在生产环境初始规划中，**不代表 Lab 部署的是生产规格**。

**录完核对：** 三个页面都拍到，鼠标有自然移动，画面只包含 Console 主体。已有的 [Part 1 视频](videos/Part1_Vincent_Console.mp4) 也能作为参考或备用镜头。

---

## 三、Part 2 — Zack：Networking & Security

**最终影片位置：03:00–07:00 · Console 共 4 分钟。** 最好先进入 VPC，再集中拍完 VPC 相关页面，最后进 Security Groups。各镜头的“25/30 秒”是 Zack 的成片目标，不是页面加载超时限制。

| 编号 / 成片位置 | 具体点哪里、依次做什么 | 页面稳定后停留 | 必须拍到 |
| --- | --- | ---: | --- |
| **2.1 / 03:00–03:30（30 秒）** | 顶部 AWS 服务搜索 **VPC** → **Your VPCs** → 搜索或筛选 Name = `anygroupllc-a2-vpc` → 点击 VPC ID → **Details** | **18 秒** | CIDR `10.0.0.0/16`，VPC 状态，Region。 |
| **2.2 / 03:30–04:00（30 秒）** | VPC 左边 **Subnets** → 过滤 **VPC = anygroupllc-a2-vpc** → 把 Name、IPv4 CIDR、Availability Zone 列显示出来 → 慢慢扫过六行 | **20 秒** | `public-a/b`、`app-a/b`、`db-a/b`，分别分布两个 AZ；CIDR 为 `10.0.0.0/24`、`10.0.1.0/24`、`10.0.10.0/24`、`10.0.11.0/24`、`10.0.20.0/24`、`10.0.21.0/24`。 |
| **2.3 / 04:00–04:30（30 秒）** | 左边 **Route tables** → 按 VPC 筛选 → 选择 `public-rt` → 下方 **Routes** | **18 秒** | `0.0.0.0/0 → igw-...` 的公有子网默认路由。 |
| **2.4 / 04:30–05:00（30 秒）** | Route tables 选择 `app-rt-a` → **Routes**；再返回选择 `app-rt-b` → **Routes** | **A 12 秒 + B 12 秒** | 两张 App Route Table 的 `0.0.0.0/0` 分别指向不同 NAT Gateway。不要拍错成 DB Route Table。 |
| **2.5 / 05:00–05:30（30 秒）** | Route tables → 选择 `db-rt-local-only` → **Routes**；把完整列表放在画面中 | **20 秒** | 只有本地 `10.0.0.0/16 → local`，**没有** `0.0.0.0/0`。这条是数据库网络隔离的重点证据。 |
| **2.6 / 05:30–06:00（30 秒）** | VPC 左边 **NAT gateways** → 过滤 VPC → 依次选中 `nat-a` / `nat-b` → 列表展开 Name、Subnet、State | **18 秒** | 两台 NAT 处于 `Available`，位于不同公有子网；注意 NAT 会持续计费。 |
| **2.7 / 06:00–06:30（30 秒）** | AWS 搜索 **EC2** → 左侧 **Network & Security → Security Groups** → 依次选择 `frontend-sg`、`db-sg` → **Inbound rules**；有时间再切 `backend-sg` 和 `internal-alb-sg` | **Frontend 11 秒 + DB 11 秒** | Frontend TCP 80 的 Source 为 Public ALB SG；DB TCP 8080 的 Source 为 Backend SG。**不要把“仅安全组允许”误讲成真实应用身份鉴权。** |
| **2.8 / 06:30–07:00（30 秒）** | 回到 **VPC** → **Network ACLs** → 选择 `public-nacl` → **Inbound rules** → 定位 TCP 443 允许规则 | **20 秒** | 从 `10.0.0.0/16` 允许入站 TCP 443；另可看到 HTTP / ephemeral 规则。**规则可见不等于已实测两个 AZ 的 HTTPS 出站。** |

**Zack 讲解顺序：** 为什么拆 Public / App / DB 三层 → IGW 只服务公有子网 → App 通过 NAT 出站 → DB 不走默认公网路由 → SG 限制上一层来源 → NACL 是补充保护。

**卡住怎么办：** 左边菜单名称可能略有变化，优先用 AWS 顶部全局搜索切服务。任何页面正在 `Loading...` 时不要把它算进停留时间。若某个资源不为 Available/规则缺失，应停止并调查，而不是配音说正常。

---

## 四、Part 3 — Sam：Reliability & Operational Excellence

**最终影片位置：07:00–11:00 · 全部 4 分钟只展示 AWS Console。** 注意：AWS Console 本身当然是在 Chrome 里打开的，但**不用新开普通网站页面，也不用输入 ALB URL、`/api/` 或 `/api/db/`**。最后 70 秒改为展示两层 ALB 的 Listener 和私有 Dummy DB 的网络隔离。

| 编号 / 成片位置 | 具体点哪里、依次做什么 | 页面稳定后停留 | 必须拍到 |
| --- | --- | ---: | --- |
| **3.1 / 07:00–07:25（25 秒）** | AWS 顶部搜索 **EC2** → 左侧 **Load Balancing → Load Balancers** → 过滤 `anygroup-` → 点击 `anygroup-public-alb` 看 **Scheme**，再点 `anygroup-internal-alb` | **每个 10 秒** | Public = `internet-facing`，Internal = `internal`；Type 均为 Application。 |
| **3.2 / 07:25–07:55（30 秒）** | EC2 左侧 **Target Groups** → `anygroup-front-tg` → **Targets** | **20 秒** | 至少 2 个 **Healthy** 的 Frontend Targets；健康检查路径为 `/health`。 |
| **3.3 / 07:55–08:25（30 秒）** | **Target Groups** → `anygroup-back-tg` → **Targets** | **20 秒** | 至少 2 个 **Healthy** 的 Backend Targets。 |
| **3.4 / 08:25–08:55（30 秒）** | 左侧 **Auto Scaling Groups** → `anygroup-frontend-asg` → **Details** → **Instance management** | **Details 12 秒 + 实例 12 秒** | Desired 2 / Min 2 / Max 4；健康实例分布在两个 AZ。 |
| **3.5 / 08:55–09:25（30 秒）** | **Auto Scaling Groups** → `anygroup-backend-asg` → **Details** → **Instance management** | **Details 12 秒 + 实例 12 秒** | Backend 同样 2 / 2 / 4，两 AZ 有 InService 实例。 |
| **3.6 / 09:25–09:50（25 秒）** | 在 ASG 中点击 **Automatic scaling** → 找到 **Target tracking scaling policy** → 展示配置 | **17 秒** | Target value = **60% average CPU**。这是扩容目标，不能说已经测过扩缩容。 |
| **3.7 / 09:50–10:10（20 秒）** | EC2 → **Load Balancers** → 选 `anygroup-public-alb` → 下方 **Listeners and rules**（有时叫 Listeners）→ 找 **HTTP:80** → 展开默认规则/Forward to | **13 秒** | Public ALB 的 **HTTP 80 Listener → `anygroup-front-tg`**。鼠标指向 Forward to，等文字清晰后再移开。 |
| **3.8 / 10:10–10:30（20 秒）** | 返回 Load Balancers → 选 `anygroup-internal-alb` → **Listeners and rules** → **HTTP:80** → 展示 Default action | **13 秒** | Internal ALB 的 **HTTP 80 Listener → `anygroup-back-tg`**。配合前面两个 Healthy Target Groups 解释路由结构。 |
| **3.9 / 10:30–11:00（30 秒）** | EC2 左侧 **Instances** → 搜索 Name = `db-tier-dummy-oracle` → 点击实例 → **Details / Networking** 展示 Private IPv4、Subnet；再点 **Security → Security Groups**，点 DB 安全组进入 **Inbound rules** | **私有子网 10 秒 + 安全组 15 秒** | Dummy DB 没有公网访问入口；DB SG 的 **TCP 8080 来源 = `backend-sg`**（Security Group ID）。这是 Dummy EC2，**不是 Oracle RDS**。 |

**重点说明：** 3.7–3.9 展示 ALB 转发规则与数据库安全边界，**只证明配置和此前健康检查的状态，不等于当场验证了完整端到端业务请求**。仓库的 `verify.sh` 另有 `/`、`/api/`、`/api/db/` 的独立测试；如果老师要求“现场证明 HTTP 真实返回”，在正式视频之外运行该脚本留存验收记录，不能把 Console 的配置画面称为 HTTP 实测。

**Sam 讲解顺序：** Public ALB → Frontend Target Group/ASG → Internal ALB → Backend Target Group/ASG → 私有 Dummy DB；为什么需要健康检查、两 AZ 和 Auto Scaling，以及哪些功能没有做真实故障恢复或数据库高可用测试。

---


## 五、Part 4 — Kevin：Additional Feature & Business Value

**最终影片位置：11:20–14:35 · Console 共 3 分 15 秒。** Kevin 的 Forecasting 架构说明 PPT（前 20 秒）和结束总结 PPT（末 25 秒）由组员自己处理。

| 编号 / 成片位置 | 具体点哪里、依次做什么 | 页面稳定后停留 | 必须拍到 |
| --- | --- | ---: | --- |
| **4.2 / 11:20–11:45（25 秒）** | **CloudFormation → `anygroupllc-a2` → Outputs** → 找 **ForecastBucket** → 复制桶名 → 搜索 **S3** → **Buckets** → 搜索并点击对应 Bucket → **Objects** | **15 秒** | 私有 Forecast Bucket、`forecast-input/` 和 `forecast-output/` 前缀；不能把桶误说成公开网站存储。 |
| **4.3 / 11:45–12:20（35 秒）** | S3 Bucket → `forecast-input/` → **Upload** → **Add files** → 选仓库的 `sample-sales.csv`（建议先在电脑保存副本并改成唯一名，例如 `demo-20261016-01.csv`）→ **Upload** → 等页面显示成功 → 回 Objects | **上传成功页至少 12 秒** | 本次全新上传的 **CSV 文件名**，成功状态。尽量用没上传过的唯一文件名，方便对照结果。 |
| **4.4 / 12:20–12:50（30 秒）** | AWS 搜索 **Lambda** → **Functions** → `anygroup-sales-forecast` → **Configuration → Triggers**（有些页面 Trigger 在 Function overview）→ 看 S3 Event | **18 秒** | S3 `ObjectCreated`；过滤规则 prefix = `forecast-input/`、suffix = `.csv`。必要时 **Monitor → View CloudWatch logs** 找刚才运行记录。 |
| **4.5 / 12:50–13:20（30 秒）** | 返回 **S3 → 同一个 Bucket → `forecast-output/` → `runs/`** → 找刚才的 `demo-20261016-01.csv.json`（实际以本次上传名为准）→ 点击对象 | **18 秒** | 对应唯一输入新生成的 JSON 文件、最近修改时间；如果没有生成，停下来检查 Lambda，不能打开旧文件冒充。 |
| **4.6 / 13:20–13:50（30 秒）** | 对对应 JSON 使用 **Open / Download** 在浏览器查看内容（AWS 界面具体入口可能因权限不同）→ 定位 `source_key`、`window_size`、`forecast_date`、`next_day_sales_forecast` | **20 秒** | `source_key` 等于刚上传的 CSV；`window_size = 7`；当前仓库样例结果应为 **559.71**。要讲这是简单移动平均，不代表真实商业预测精度。 |
| **4.7 / 13:50–14:15（25 秒）** | AWS 搜索 **CloudWatch** → **Alarms → All alarms** → 选择 `anygroup-frontend-high-cpu` → **Details** | **17 秒** | CPU 大于 **70%**、Period **300 秒 × 2 次**、Alarm action 指向 SNS。**不必人为触发 CPU 告警**，更不应说邮件已发。 |
| **4.8 / 14:15–14:35（20 秒）** | AWS 搜索 **SNS / Simple Notification Service** → **Topics** → `anygroup-infrastructure-alarms` → 看 **Subscriptions** | **12 秒** | SNS Topic 存在；如订阅为 `PendingConfirmation` 或没有订阅，明确说明**目前仅配置了通知链路，未证明邮件已送达**。 |

### Part 4 小技巧（避免最容易出现的假阳性）

- `sample-sales.csv` 在仓库根目录，可直接从 GitHub 下载到录屏设备再上传。
- 输出不是直接把输入 CSV 复制一份，而是由 **S3 ObjectCreated → Lambda → S3 JSON** 自动生成；等待几十秒属于正常情况。
- **优先拍 `forecast-output/runs/<本次文件名>.json`，不要只拍 `forecast-output/latest.json`**，后者可能是以前生成的。
- 用此样例预测 **559.71**，并说明“下一日销量的七日简单移动平均原型”；没有处理节假日、促销、库存或模型效果评估。
- Kevin 在结尾串起 CFO 的用例：历史日销售 → 自动汇总 → 下一日预测值 → 采购部门参考；绝不声称已连接真实公司 ERP 或 Oracle。

---

## 六、录制、交付和剪辑操作清单

### 每段录制的固定操作

- [ ] 打开对应 AWS 页面，让加载结束；确认没有弹出的 AWS Details、密码、Token、私人邮件。
- [ ] 开始录制后先停 **3 秒**，再正常移动鼠标；每次转场鼠标移动 0.5–1 秒，点击前停一会儿。
- [ ] 核心数值或状态出现在屏幕上后保持 **12–20 秒**，不要滑得太快。
- [ ] 拍完一个 Part 再停止并保存，立刻打开成片回放 **开头/中间/结尾**，确认光标可见、内容清晰且没有浏览器 Tab。
- [ ] 视频命名 `PartN_姓名_Raw.mp4`；把它和对应镜头编号告诉 Zack。
- [ ] 如果画面出错，只重拍这个镜头；不必重新拍完整 Part。

### Zack 剪辑注意

1. 最终顺序固定 **Vincent 3 分 → Zack 4 分 → Sam 4 分 → Kevin 4 分**。
2. Console 段落依照上面的绝对时间段剪；如某一页需要更长解释，优先压缩页面转换过程而不是砍掉核心证据。
3. Vincent PPT、业务架构图、生产规格和 Kevin 收尾由组员插入；不要在同一个镜头把 PPT 静态截图伪装成 AWS Console 运行页面。
4. 按说话人分别配英文录音；没有现场录音也没关系，画面按配音来对齐。四个人必须能解释自己负责的技术内容。
5. 成片建议 H.264 MP4、1080p、30fps，声音尽量统一。最终提交 PDF/Slides，以及**单独一个 `.txt` 文件写可访问的视频 URL**；所有成员记得提交 TeamMates。
6. **小组录完并备份验证后再删除 Lab 资源**；录制期间也要注意两台 NAT Gateway、两台 ALB 和 EC2 的持续收费。

### 实际录屏工具怎么选

- **Mac：** OBS 的显示器/窗口捕获更方便配置裁切，也可使用 macOS 屏幕录制。录制区域只覆盖 AWS Console 内容，录屏选项开启 **显示鼠标指针**。
- **Windows：** OBS 窗口捕获/显示器捕获，手动裁掉 Chrome 标签栏、地址栏及任务栏。开始前录 8 秒并回放检查。
- **两端统一：** 如果选定的工具不显示鼠标指针，要先改捕获选项或换录制模式。不要为了“鼠标看起来真人”额外录鼠标练习视频；**你正常操作本来就有自然轨迹**。

---

## 七、快速检查表：什么情况不能硬说已经成功

| 现象 | 拍摄处理 |
| --- | --- |
| CloudFormation 尚未 `CREATE_COMPLETE` / `UPDATE_COMPLETE` | 等待完成或排错后再拍 |
| Frontend / Backend Target Group 不满两个 Healthy | 暂停 Part 3，检查 ASG、Target Health、User Data |
`verify.sh` 的 HTTP 接口校验失败 | 作为单独的工程验收问题记录；Part 3 Console 镜头不能冒充 HTTP 请求成功 |
| Forecast 输出文件未生成 | 等 Lambda、检查触发器及日志；不使用旧的 `latest.json` |
| CloudWatch 为 `INSUFFICIENT_DATA` | 可讲配置存在，但不能讲告警已经触发成功 |
| SNS Topic 无 Confirmed 订阅 | 只演示配置，不声称邮件送达 |
| DB 页面显示 Dummy JSON | 清楚说明**模拟网络层**，不是实际 Oracle RDS |
| AWS 资源已销毁或 Lab Token 失效 | **无需为拍摄脚本本身重新部署**；要拍真实 Console，必须先有活跃环境 |

**一页总结：** 只录每部分的真实 AWS Console 证据，画面保持稳定，鼠标自然点击；具体技术分析和商业背景由四人 PPT + 英文配音承担。控制好时长，但永远先保证证据是真的、清楚、没有敏感内容。
