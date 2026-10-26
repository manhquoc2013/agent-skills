# Hướng dẫn sử dụng Agent Skills

Tài liệu hướng dẫn sử dụng bộ skill trong repo này — dành cho người dùng tiếng Việt. Căn cứ trực tiếp trên 26 skill trong `skills/`, 9 slash command trong `.claude/commands/`, 4 persona trong `agents/`, và các quy tắc phối hợp trong `AGENTS.md` + `docs/skill-anatomy.md`.

## 1. Tổng quan

Repo chứa ba lớp có nhiệm vụ khác nhau:

| Lớp | Vị trí | Vai trò |
|---|---|---|
| **Skills** | `skills/<tên>/SKILL.md` | Quy trình làm việc có bước và tiêu chí thoát — *làm thế nào* |
| **Personas** | `agents/<vai-trò>.md` | Vai trò chuyên gia với góc nhìn và định dạng đầu ra riêng — *ai làm* |
| **Slash commands** | `.claude/commands/*.md` | Điểm vào cho người dùng — *khi nào* |

Cách dùng cơ bản: mô tả việc cần làm bằng ngôn ngữ tự nhiên. Agent sẽ tự ánh xạ ý định của bạn sang skill phù hợp và thực thi đúng quy trình. Bạn không cần nhớ tên skill — nhưng biết bản đồ ánh xạ giúp bạn kiểm soát được agent đang đi đúng đường hay không.

**Nguyên tắc bắt buộc:** nếu công việc khớp một skill (dù chỉ 1%), agent phải gọi skill đó thay vì tự làm. Không có ngoại lệ kiểu "việc này nhỏ, làm nhanh cho xong".

## 2. Bản đồ ý định → skill

| Bạn nói… | Skill được kích hoạt |
|---|---|
| Tính năng mới / thêm chức năng | `spec-driven-development` → `incremental-implementation` + `test-driven-development` |
| Lập kế hoạch / chia nhỏ công việc | `planning-and-task-breakdown` |
| Bug / lỗi / hành vi bất thường | `debugging-and-error-recovery` |
| Review code | `code-review-and-quality` |
| Refactor / đơn giản hóa | `code-simplification` |
| Thiết kế API / interface | `api-and-interface-design` |
| Việc liên quan UI | `frontend-ui-engineering` |
| Đọc spec/PRD/ticket có sẵn và hỏi còn điểm gì chưa rõ | `document-clarification` → `spec-driven-development` |

## 3. Vòng đời công việc

Một tính năng hoàn chỉnh đi qua các giai đoạn, mỗi giai đoạn có skill riêng:

| Giai đoạn | Skill | Nhiệm vụ |
|---|---|---|
| **DEFINE** | `document-clarification` → `spec-driven-development` | Làm rõ điểm mở của tài liệu có sẵn, rồi viết spec trước khi code |
| **PLAN** | `planning-and-task-breakdown` | Chia thành các task có tiêu chí chấp nhận |
| **BUILD** | `incremental-implementation` + `test-driven-development` | Cài đặt từng lát mỏng, test trước code sau |
| **VERIFY** | `debugging-and-error-recovery` | Khi test/build đỏ — tìm nguyên nhân gốc |
| **REVIEW** | `code-review-and-quality` | Review 5 trục trước khi merge |
| **SHIP** | `shipping-and-launch` | Checklist trước khi lên production |

## 4. Catalog 26 skill

### 4.1 Điều phối & meta (4)

**`using-agent-skills`** — Skill meta: khám phá và gọi các skill khác.
Dùng khi: bắt đầu phiên làm việc, hoặc cần quyết định skill/quy trình nào áp dụng cho công việc hiện tại. Là "sổ tay" chi phối cách mọi skill khác được tìm và gọi.

**`context-engineering`** — Tối ưu ngữ cảnh của agent.
Dùng khi: bắt đầu phiên mới, chất lượng đầu ra của agent suy giảm, chuyển đổi giữa các nhiệm vụ, hoặc cần cấu hình rules file và context cho dự án.

**`idea-refine`** — Mài ý tưởng thô thành khái niệm sắc nét qua tư duy phân kỳ (mở rộng) rồi hội tụ (thu hẹp).
Dùng khi: ý tưởng còn mơ hồ, cần stress-test giả định trước khi cam kết vào kế hoạch, hoặc muốn mở rộng lựa chọn trước khi chốt một hướng. Kích hoạt bởi: "ideate", "refine this idea", "stress-test my plan".

**`interview-me`** — Khai thác điều người dùng *thực sự* muốn (không phải điều họ nghĩ họ muốn), bằng phỏng vấn một-câu-hỏi-một-lần cho đến ~95% chắc chắn về ý định.
Dùng khi: yêu cầu thiếu thông tin ("build cho tôi X" mà không có "cho ai", "tại sao bây giờ"), hoặc người dùng nói "interview me", "grill me", "are we sure?".

### 4.2 Định nghĩa & lập kế hoạch (5)

**`document-clarification`** — Biến điểm mơ hồ của một tài liệu có sẵn (spec, PRD, ticket) thành danh sách câu hỏi có cấu trúc.
Dùng khi: đã có tài liệu nhưng còn điểm mở cần chốt trước khi lập kế hoạch; muốn biết tài liệu còn để ngỏ gì; cần chuyển các lỗ hổng thành câu hỏi kèm bằng chứng, mức độ ưu tiên và giá trị mặc định gợi ý. **Không dùng để** tự viết spec từ yêu cầu mơ hồ — đó là `spec-driven-development`.

**`spec-driven-development`** — Tạo spec trước khi code.
Dùng khi: bắt đầu dự án/tính năng/thay đổi lớn mà chưa có spec; nháp PRD hoặc tài liệu yêu cầu; yêu cầu mơ hồ hoặc chỉ tồn tại như ý tưởng; một yêu cầu trải trên nhiều năng lực cần tách thành capability map.

**`planning-and-task-breakdown`** — Chia công việc thành các task có thứ tự.
Dùng khi: đã có spec hoặc yêu cầu rõ ràng và cần chia thành task cài đặt được; task quá lớn để bắt đầu; cần ước lượng phạm vi; có thể làm song song.

**`source-driven-development`** — Neo mọi quyết định cài đặt vào tài liệu chính thức.
Dùng khi: muốn kiểm chứng cách tiếp cận với tài liệu chính thức trước khi cài đặt, hoặc muốn code có căn cứ nguồn, không dùng pattern lỗi thời. Dùng với mọi framework/thư viện nơi tính đúng đắn quan trọng.

**`constraint-driven-development`** — Lập "thanh chất lượng" của dự án thành hợp đồng viết (CONSTRAINTS.md) và ngăn agent âm thầm hạ thấp nó.
Dùng khi: chưa có thanh chất lượng viết ra; người dùng nói "set up constraints" / "define our standards"; agent liên tục tắt check hoặc bỏ test để chạy xanh; cần ngưỡng coverage/performance nhưng không biết chọn số nào.

### 4.3 Xây dựng (4)

**`incremental-implementation`** — Giao thay đổi theo từng lát mỏng, kiểm chứng được.
Dùng khi: cài đặt tính năng chạm nhiều hơn một tệp; nhặt task tiếp theo từ kế hoạch; cần triển khai sau feature flag; sắp viết một lượng lớn code một lúc; task quá to để "land" một phát.

**`test-driven-development`** — Phát triển bằng vòng lặp đỏ-xanh-refactor.
Dùng khi: cài đặt bất kỳ logic nào, sửa bất kỳ bug nào, thay đổi bất kỳ hành vi nào; cần chứng minh code chạy đúng; có bug report; được yêu cầu thêm test hoặc sửa hàm — kể cả khi code chỉ được dán vào và yêu cầu không nhắc tới test.

**`frontend-ui-engineering`** — Xây UI chất lượng production: truy cập được, responsive, đúng design system.
Dùng khi: xây hoặc sửa giao diện, tạo component, cài đặt layout, đáp ứng yêu cầu WCAG, quản lý state — hoặc khi đầu ra cần *trông* như production chứ không phải "AI-generated". Lưu ý: Verification có cổng **SEE IT** — thay đổi UI chưa nhìn thấy render thì chưa xong.

**`api-and-interface-design`** — Thiết kế API và interface ổn định.
Dùng khi: thiết kế API, ranh giới module, bất kỳ interface công khai nào; tạo endpoint REST/GraphQL; định nghĩa type contract giữa các module; phân ranh giới frontend/backend.

### 4.4 Chất lượng, bảo mật & xác minh (6)

**`browser-testing-with-devtools`** — Test trên trình duyệt thật qua Chrome DevTools MCP.
Dùng khi: xây hoặc debug bất kỳ thứ gì chạy trên trình duyệt; cần soi DOM, bắt console error, phân tích network, profile hiệu năng, xác minh output trực quan bằng dữ liệu runtime thật. **Điều kiện:** cần cấu hình chrome-devtools MCP server.

**`code-review-and-quality`** — Review code 5 trục: correctness, readability, architecture, security, performance.
Dùng khi: trước khi merge bất kỳ thay đổi nào; đánh giá code do chính bạn, agent khác, hoặc người viết; được yêu cầu review diff/PR — kể cả diff dán thẳng vào chat. Verdict có 3 giá trị (Approve / Request changes / Escalate), tư thế mặc định là **từ chối cho tới khi có bằng chứng do chính reviewer tạo ra** (test tự chạy lại, build tự chạy, màn hình tự mở).

**`code-simplification`** — Đơn giản hóa code cho rõ ràng, không đổi hành vi.
Dùng khi: refactor vì code khó đọc/bảo trì/mở rộng dù vẫn chạy; review code đã tích tụ phức tạp không cần thiết.

**`doubt-driven-development`** — Đưa mọi quyết định không tầm thường qua một reviewer fresh-context đối kháng trước khi nó được chốt.
Dùng khi: muốn mọi giả định bị thẩm vấn chéo trước khi tiếp tục; stress-test kế hoạch tìm failure mode ẩn; correctness quan trọng hơn tốc độ; code lạ; rủi ro cao (auth production, logic nhạy cảm bảo mật, migration lớn, thao tác không đảo ngược được).

**`security-and-hardening`** — Gia cố code chống lỗ hổng.
Dùng khi: audit input handler; xử lý input người dùng, xác thực, lưu trữ dữ liệu, tích hợp bên ngoài; kiểm tra login flow theo OWASP Top Ten; xây tính năng nhận dữ liệu không tin cậy; audit dependency tìm CVE; dữ liệu cá nhân hoặc tuân thủ GDPR/CCPA.

**`performance-optimization`** — Tối ưu hiệu năng frontend, backend, query, database.
Dùng khi: có yêu cầu hiệu năng; nghi ngờ regression; cần cải thiện Core Web Vitals; sửa N+1 query; profiling phát hiện nút thắt.

### 4.5 Sự cố & vận hành (7)

**`debugging-and-error-recovery`** — Debug tìm nguyên nhân gốc có hệ thống.
Dùng khi: test đỏ, build vỡ, thứ hôm qua còn chạy hôm nay hỏng, hành vi sai kỳ vọng, bất kỳ lỗi bất ngờ nào. **Cổng bắt buộc:** chưa có một lệnh fail tái hiện được thì chưa sang bước tìm nguyên nhân — không đoán mò.

**`ci-cd-and-automation`** — Tự động hóa pipeline CI/CD và quality gate.
Dùng khi: thiết lập hoặc sửa build/deploy pipeline; tự động hóa quality gate; cấu hình test runner trong CI; thiết lập chiến lược deploy. Khi CI đỏ: **phân loại lỗi trước khi sửa** — Flake (chạy lại trước), Regression (tái hiện + test bảo vệ), Environment (escalate cho người, không sửa bằng code), Config (sửa config, không sửa code sản phẩm).

**`observability-and-instrumentation`** — Đo đạc để hành vi production nhìn thấy và chẩn đoán được.
Dùng khi: thêm logging, metrics, tracing, alerting; ship tính năng chạy production cần bằng chứng nó hoạt động; sự cố production mà không biết chuyện gì đã xảy ra từ dữ liệu hiện có.

**`shipping-and-launch`** — Chuẩn bị cho production.
Dùng khi: chuẩn bị deploy production; cần pre-launch checklist; thiết lập giám sát; lập staged rollout; cần chiến lược rollback.

**`documentation-and-adrs`** — Ghi quyết định và tài liệu (ADR — Architecture Decision Record).
Dùng khi: cần ghi quyết định kiến trúc hoặc lý do đằng sau lựa chọn thiết kế; thay đổi public API; ship tính năng; ghi ngữ cảnh cho kỹ sư và agent tương lai. **Không dùng cho:** code hiển nhiên, comment lặp lại code, doc cho prototype vứt đi.

**`deprecation-and-migration`** — Quản lý khai tử và di trú.
Dùng khi: gỡ hệ thống/API/tính năng cũ; di trú người dùng giữa các cài đặt; di trú schema database production không downtime (expand/contract); quyết định bảo trì hay khai tử code hiện có.

**`git-workflow-and-versioning`** — Kỷ luật git: commit là save point, branch là sandbox, lịch sử là tài liệu.
Dùng khi: mọi thay đổi code — commit, branch, giải quyết conflict, tách working tree bừa bộn thành các commit nguyên tử, mở/review PR, push, cắt release, chọn semver, viết changelog, hoặc tổ chức nhiều luồng công việc song song (worktree).

## 5. Slash commands (12 lệnh)

| Lệnh | Skill tương ứng | Mô tả |
|---|---|---|
| `/s-agent` | autonomous-agent-workflow | Autopilot đầu cuối: phỏng vấn modal, spec, plan, sub-agent song song, tự sửa lỗi TDD |
| `/s-spec` | spec-driven-development | Viết spec có cấu trúc trước khi code; nếu yêu cầu gồm nhiều năng lực độc lập → capability map trước |
| `/s-plan` | planning-and-task-breakdown | Chia việc thành task nhỏ có tiêu chí chấp nhận; lưu `tasks/plan.md` + `tasks/todo.md` |
| `/s-build` | incremental-implementation + test-driven-development | Cài đặt task kế tiếp rồi dừng; `/s-build auto` = duyệt kế hoạch một lần rồi chạy hết các task (vẫn test-từng-task + commit-từng-task) |
| `/s-test` | test-driven-development | Vòng đỏ-xanh-refactor; với bug dùng Prove-It pattern (test tái hiện bug phải ĐỎ trước) |
| `/s-debug` | debugging-and-error-recovery | Điều tra lỗi & Root Cause; mặc định fix + test; `--find` chỉ điều tra báo cáo bằng chứng mà không sửa code |
| `/s-debt` | technical-debt-and-shortcuts | Quản lý nợ kỹ thuật: theo dõi trần kỹ thuật, điều kiện nâng cấp và rủi ro mọt code |
| `/s-review` | code-review-and-quality | Review 5 trục với file:line cụ thể |
| `/s-ship` | shipping-and-launch | Fan-out song song 3 persona (code-reviewer, security-auditor, test-engineer) → quyết định GO/NO-GO + rollback plan |
| `/s-perf` | web-performance-auditor (persona) | Audit hiệu năng web; chế độ Deep (có dữ liệu Lighthouse/PSI/CrUX) hoặc Quick (soi cấu trúc code) |
| `/s-simplify` | code-simplification | Đơn giản hóa code, giữ nguyên hành vi |
| `/s-guard` | constraint-driven-development | Thiết lập thanh chất lượng; sub-command: `check`, `diff`, `ratchet` |

## 6. Personas (4 vai trò)

| Persona | Vai trò | Dùng khi |
|---|---|---|
| `code-reviewer` | Review 5 trục: correctness, readability, architecture, security, performance | Fan-out của `/s-ship`, hoặc review độc lập |
| `security-auditor` | Audit lỗ hổng: OWASP Top 10, secrets, auth/authz, CVE dependency | Fan-out của `/s-ship`, hoặc audit bảo mật riêng |
| `test-engineer` | Phân tích độ phủ test: happy path, edge case, error path, concurrency | Fan-out của `/s-ship`, hoặc đánh giá bộ test |
| `web-performance-auditor` | Audit hiệu năng web với scorecard chỉ ghi giá trị có nguồn | `/s-perf` |

**Quy tắc phối hợp:** người dùng (hoặc slash command) là người điều phối. Persona không gọi persona khác. Mẫu phối hợp duy nhất là **fan-out song song + merge** — đúng như `/s-ship`: ba persona chạy đồng thời, kết quả được tổng hợp ở phiên chính. Có thể bỏ qua fan-out chỉ khi: thay đổi ≤ 2 tệp, diff < 50 dòng, và không đụng auth, payments, data access, config/env.

## 7. Kịch bản thực hành

**Tính năng mới từ ý tưởng mơ hồ:**
1. `idea-refine` — mài ý tưởng; nếu vẫn thiếu thông tin → `interview-me` để khai thác ý định thật
2. `spec-driven-development` — viết spec (hoặc `/s-spec`)
3. `planning-and-task-breakdown` — chia task (hoặc `/s-plan`)
4. `incremental-implementation` + `test-driven-development` — cài từng task (hoặc `/s-build`, `/s-build auto`)
5. `code-review-and-quality` — review trước merge (hoặc `/s-review`)
6. `shipping-and-launch` — checklist + rollback (hoặc `/s-ship`)

**Sửa bug:**
1. `debugging-and-error-recovery` — tái hiện bằng một lệnh fail (bắt buộc), rồi bisect/khoanh vùng
2. `test-driven-development` — Prove-It: test tái hiện bug phải đỏ trước, sửa, xanh
3. `code-review-and-quality` — review cả fix lẫn regression test

**Refactor:** `code-simplification` (hoặc `/s-simplify`) — từng bước một, chạy test sau mỗi bước, revert bước nào làm test đỏ.

**Làm UI:** `frontend-ui-engineering` — design system trước, rồi component; kết thúc bằng cổng SEE IT: mở app nhìn ở desktop + mobile, mọi trạng thái.

**CI đỏ:** `ci-cd-and-automation` — phân loại Flake/Regression/Environment/Config trước khi sửa.

**Lên production:** `shipping-and-launch` — bắt buộc có rollback plan trước khi GO; bất kỳ Critical finding nào từ fan-out → mặc định NO-GO trừ khi bạn chấp nhận rủi ro tường minh.

## 8. Nguyên tắc dùng đúng

1. **"When NOT to use" quan trọng như "When to Use".** Mỗi skill khai báo phạm vi loại trừ — đọc cả hai chiều. Ví dụ: lỗi CI môi trường không sửa bằng code; doc cho prototype vứt đi thì không viết.
2. **Không bỏ bước.** Skill định nghĩa quy trình có exit criteria — không có chuyện "áp dụng một phần". `## Verification` là cổng thoát bắt buộc với bằng chứng thật (test output, build result, màn hình render), không phải "có vẻ đúng".
3. **Khi skill xung đột, skill gần và hẹp hơn thắng.** Thứ tự ưu tiên: (1) chỉ thị tường minh của skill đang chạy, (2) skill đặc thù cho task hơn skill tổng quát, (3) hợp đồng cấp pack (`using-agent-skills`, `references/definition-of-done.md`, `docs/skill-anatomy.md`), (4) hành vi mặc định. Vẫn xung đột → nêu ra và hỏi, không đoán.
4. **Kỷ luật git chạy xuyên suốt.** Mọi thay đổi code đi qua `git-workflow-and-versioning`: commit nguyên tử, message giải thích ý định, một commit một việc.
5. **Bằng chứng trước, tuyên bố sau.** Test phải tự chạy lại, build phải tự chạy, UI phải tự mở nhìn — câu chuyện xác minh của người viết code là claim chưa kiểm chứng, không phải bằng chứng.

## 9. Tài liệu liên quan

- `AGENTS.md` — ánh xạ ý định → skill và vòng đời (nguồn chính của mục 2, 3)
- `docs/skill-anatomy.md` — chuẩn cấu trúc một skill (frontmatter, section, ngưỡng context)
- `docs/agents.md` — ma trận quyết định persona
- `references/orchestration-patterns.md` — catalog mẫu phối hợp đầy đủ
- `README.md` — hướng dẫn cài đặt cho từng harness
