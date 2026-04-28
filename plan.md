# Donation Platform System Design (Full Product Specification)

## 🧠 1. Overview
A donation platform that connects donors with verified beneficiaries through a controlled system ensuring:
- Verification before publishing cases
- Centralized payment processing
- Transparent donation tracking
- Admin-controlled payouts

---

## 🚀 2. Core Principles
- One user = one phone number (no duplicates)
- Each user has ONE role only:
  - Donor
  - Beneficiary
- No direct donor-to-beneficiary money transfer
- All payments go through the platform first
- Admin approval is required for sensitive actions

---

## 👤 3. Authentication System

### Flow:
1. User enters phone number
2. OTP verification via entity["company","Paymob","Egypt payment gateway"] or SMS provider
3. Firebase Auth creates user session
4. System determines role and routes user

### Rules:
- Phone number is unique (no duplicate accounts)
- Login is OTP-based only (no passwords)

---

## 🧭 4. App Entry Flow

```text
Splash
↓
First Time Check
↓
Onboarding (if first time)
↓
OTP Login
↓
Role Routing
```

### Routing:
- Donor → Feed (Cases)
- Beneficiary → Verification / Dashboard

---

## 🎯 5. Onboarding

3 screens:
1. Platform concept
2. Trust & verification system
3. Impact of donations

---

## 🟢 6. Donor System

### Features:
- Browse donation cases
- Donate to cases
- Donate to platform
- View donation history

### Donor Profile:
- Total donations
- Donation history
- Impact summary
- Optional display name

---

## 🔴 7. Beneficiary System

### Registration Data:
- Personal information
- Family size
- Income status
- Health condition
- Debt information
- Payout method (Vodafone Cash / Bank)
- National ID

### Status:
- pending_verification
- approved
- rejected

### Rules:
- Cannot appear in the system before approval

---

## 🧑‍💼 8. Case System

### Case Fields:
- title (general, anonymized)
- category (Medical / Living / Emergency / Debt)
- target amount
- collected amount
- status
- verification flag

### Lifecycle:
```text
collecting
↓
completed
↓
open_for_support (optional)
```

### Rules:
- Target is fixed
- Donations stop at completion
- Post-completion support allowed (same case only)

---

## 💰 9. Donation System

### Types:
- Case Donation
- Platform Donation (separate)

### Flow:
1. User donates
2. Payment processed
3. Webhook confirms payment
4. Case updated
5. Notification sent

### Donation Options:
- Anonymous
- Show name (optional)

### Donation Model:
- amount
- caseId
- donorId
- isAnonymous
- displayName

---

## 🔄 10. Real-Time System

- Live updates using Firestore listeners
- Instant UI updates for:
  - donation progress
  - case completion
  - feed updates

### Rule:
- No polling
- Fully real-time system

---

## 💳 11. Payment System

- Visa / Mastercard
- Vodafone Cash
- via Paymob integration

### Rules:
- No manual confirmation
- Webhook is the single source of truth

---

## 🏦 12. Wallet System

- Case Wallet
- Platform Wallet (separate)

### Rules:
- No mixing between wallets
- Full traceability required

---

## 💸 13. Payout System

### Flow:
1. Case reaches target
2. Case marked completed
3. Admin reviews
4. Admin approves payout
5. Money sent via Vodafone Cash / Bank
6. Status = paid

### Rule:
- No automatic payouts
- Admin approval required

---

## 🔔 14. Notification System

### Donor Notifications:
- Donation success
- Case progress updates
- Case completed
- Post-completion support confirmation

### Beneficiary Notifications:
- Verification approved/rejected
- Donation received
- Case completed
- Payout sent

### Admin Notifications:
- New case request
- Suspicious activity
- Large donations

### Structure:
- In-app + push notifications
- Event-driven system

---

## 🔐 15. Privacy Rules

### Donor can see:
- Case cards only
- Progress
- Public donations

### Donor cannot see:
- Beneficiary identity
- Sensitive personal data

---

## 📊 16. Feed System

### Sections:
- All cases
- Emergency
- Medical
- Living
- Debt
- Completed cases

### Rules:
- Max 5–6 categories
- Sorted by priority score
- Real-time updates

---

## 🧑‍💻 17. Admin System

### Features:
- Verify beneficiaries
- Approve/reject users
- Monitor cases
- Manage donations
- Execute payouts

### Screens:
- Pending verification
- Active cases
- Completed cases
- Payout queue
- Transactions

### Fraud Control:
- Suspicious activity detection
- User blocking
- Case freezing

---

## 🧾 18. Donation Visibility System

- User chooses:
  - Show name
  - Anonymous

### Rules:
- Name is fixed at donation time
- Cannot be changed later

---

## 🏁 19. Case Completion Logic

### When a case reaches target:
- Stop main donations
- Mark as completed
- Notify beneficiary
- Open optional support mode

### Two stages:
1. Completion notification
2. Payout notification

---

## ⚡ 20. Key System Architecture

```text
User → OTP → Role → Feed / Verification
Feed → Donation → Webhook → Case Update
Case → Completion → Admin Review → Payout
```

---

## ⚠️ 21. Technical Gaps & Production Considerations

## 💳 1) Concurrency & Race Conditions
Firestore updates must be atomic to prevent inconsistencies in `collected_amount`.

### Solution:
- Use Firestore Transactions or Cloud Functions
- Prevent direct client-side financial updates

---

## 🔄 2) Payment Webhook Reliability
Reliance on entity["company","Paymob","Egypt payment gateway"] webhooks alone is risky.

### Solution:
- Reconciliation system
- Scheduled jobs to verify pending payments

---

## 📁 3) Media & Document Storage
Users upload:
- IDs
- Medical reports
- Proof documents

### Solution:
- Firebase Storage
- Encryption at rest
- Admin-only access

---

## 🧾 4) Database Structure & Audit Trail
- Full audit logs for admin actions
- Pagination for feeds (infinite scroll)

---

## ⚖️ 5) Legal & Compliance (Egypt)
- Terms & Conditions required
- Compliance with donation regulations
- Full Arabic RTL support

---

## 🧪 6) DevOps & Environments
- Staging & Production environments
- Firebase Security Rules separation
- Payment testing environment

---

## 🧠 Final Outcome
A production-ready donation platform with:
- Role-based system
- Real-time donation tracking
- Secure payment flow
- Admin-controlled payouts
- Privacy-first design
- Fully scalable architecture


---

## 🧱 22. Secure File Storage API Design (Storj + Firebase Functions)

This section defines a complete secure file handling system using entity["company","Storj","decentralized cloud storage"] integrated with entity["company","Firebase Cloud Functions","serverless backend"].

### 🧠 Architecture
```
Flutter App
    ↓ (HTTPS API)
Firebase Cloud Functions (Backend)
    ↓ (S3-compatible SDK)
Storj Private Bucket
```

No direct access from client to storage.

---

### 🗂️ Storage Structure
```
beneficiaries/{userId}/id_card.jpg
beneficiaries/{userId}/medical_report.pdf
beneficiaries/{userId}/debt_proof.pdf
```

---

## 🔌 API Endpoints

### 1) Init Upload (Generate Signed URL)
**POST** `/init-upload`

**Request:**
```json
{
  "fileName": "id_card.jpg",
  "contentType": "image/jpeg"
}
```

**Response:**
```json
{
  "uploadUrl": "SIGNED_PUT_URL",
  "filePath": "beneficiaries/{userId}/id_card.jpg"
}
```

---

### 2) Confirm Upload
**POST** `/confirm-upload`

**Request:**
```json
{
  "filePath": "beneficiaries/{userId}/id_card.jpg"
}
```

**Response:**
```json
{
  "status": "stored"
}
```

---

### 3) Get File (Signed Access)
**GET** `/file?path=...`

**Response:**
```json
{
  "url": "SIGNED_GET_URL",
  "expiresIn": 300
}
```

Used for secure admin-only viewing.

---

### 4) Delete File
**DELETE** `/file?path=...`

**Response:**
```json
{
  "status": "deleted"
}
```

---

## 🔄 Upload Flow
```
Flutter → init-upload → Cloud Function
Cloud Function → signed URL
Flutter → direct upload to Storj
Flutter → confirm-upload → metadata saved
```

---

## 👁️ File Access Flow
```
Admin → request file
Cloud Function → validate role
Cloud Function → signed GET URL
Admin → view file temporarily
```

---

## ⚙️ Security Rules
- No client direct access to Storj
- Signed URLs expire (5 minutes recommended)
- User can only upload to own folder
- Admin only can access all files

---

## 🧾 Metadata Model
```json
{
  "userId": "abc123",
  "path": "beneficiaries/abc123/id_card.jpg",
  "type": "id_card",
  "createdAt": 123456789
}
```

---

## 🔐 Key Security Rules
- Validate Firebase Auth in all functions
- Prevent cross-user file access
- Restrict file types (image/pdf only)
- Limit file size (recommended < 5MB)
- Never expose storage credentials to client

---

## 🧠 Summary
This system provides:
- Secure private document storage
- No direct client-to-storage access
- Admin-controlled file access
- Scalable S3-compatible architecture using Storj


---

## 📘 23. Development Guidelines (Critical Rules)

These rules must be followed strictly across the entire Flutter codebase.

### 🧠 Engineering Mindset
- Act as a **Senior Flutter Developer** at all times
- Build scalable, production-ready architecture
- Think in terms of maintainability and long-term growth

---

## 🏗️ Architecture Rules
- Always use **Clean Architecture** (Data / Domain / Presentation layers)
- No business logic inside UI widgets
- All features must be modular and isolated

---

## 🚫 State Management Rules
- ❌ Never use `setState`
- ✅ Always use `ValueNotifier` and `ValueListenableBuilder`
- Prefer reactive, lightweight state management

---

## 📏 Code Quality Rules
- No file should exceed **120–160 lines max**
- If a file grows, it MUST be split immediately
- Reuse all components (no duplication)

---

## 🧩 Reusability Rules
- Always reuse UI components:
  - Buttons
  - TextFields
  - Cards
  - Loading indicators
- Create a shared `core/widgets` system

---

## 🔄 CI/CD Requirement
- Implement CI/CD pipeline that:
  - Builds APK automatically
  - Runs tests before build
  - Fails build on lint errors

---

## 📦 Feature Completion Rule
After completing any feature:
- Generate an **MD file report** including:
  - What is completed
  - What is pending
  - Known issues (if any)
  - Next recommended steps

---

## ⚙️ Final Engineering Constraints
- No shortcuts in architecture
- No direct logic in UI layer
- No duplicated widgets or services
- Everything must be testable and scalable

---

## 🧠 Summary
This project must always follow:
- Clean Architecture
- Cubit state management
- Reactive state management (ValueNotifier only)
- Strict file size limits
- High reusability
- CI/CD automation
- Senior-level Flutter engineering standards

