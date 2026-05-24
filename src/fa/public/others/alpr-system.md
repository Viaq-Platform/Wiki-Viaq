# معماری کامل سیستم ALPR ایرانی
## همراه با نوع ارتباط بین سرویس‌ها

```text
┌──────────────────────────────┐
│       RTSP Cameras           │
│                              │
│  Hikvision / Dahua / Uniview │
│                              │
│  Protocol: RTSP Stream       │
└──────────────┬───────────────┘
               │
               │ RTSP
               │ (Video Stream)
               ▼
┌──────────────────────────────┐
│        Node.js Server        │
│       Control Layer          │
│                              │
│ وظایف:                       │
│                              │
│ - RTSP Stream Reader         │
│ - Frame Capture              │
│ - Frame Skipping             │
│ - Queue Management           │
│ - Temporal Tracking          │
│ - Multi-frame Voting         │
│ - Duplicate Suppression      │
│ - WebSocket Events           │
│ - REST/gRPC Client           │
│ - PMS Adapter                │
│ - Logging                    │
│ - Barrier Decision Logic     │
└──────────────┬───────────────┘
               │
               │ HTTP REST
               │ یا gRPC
               │ JSON Request
               ▼
┌──────────────────────────────┐
│      Python AI Service       │
│                              │
│ Framework:                   │
│ FastAPI / Flask              │
│                              │
│ وظایف:                       │
│                              │
│ - YOLO Plate Detector        │
│ - Crop Plate                 │
│ - OCR-only Detector          │
│ - Persian OCR                │
│ - Reconstruction Engine      │
│ - Regex Validation           │
│ - Confidence Filtering       │
│ - NMS                        │
│ - Final Plate Generation     │
└──────────────┬───────────────┘
               │
               │ HTTP Response
               │ JSON Result
               ▼
┌──────────────────────────────┐
│        Node.js Server        │
│                              │
│ نتیجه AI را دریافت می‌کند    │
│                              │
│ مثال خروجی:                  │
│                              │
│ {                            │
│   plate: "12ب34567",         │
│   confidence: 0.91,          │
│   bbox: [x1,y1,x2,y2]        │
│ }                            │
│                              │
│ سپس:                         │
│                              │
│ - Validation                 │
│ - Event Creation             │
│ - Database Logging           │
│ - Duplicate Check            │
│ - Barrier Trigger            │
│ - WebSocket Broadcast        │
└──────────────┬───────────────┘
               │
               │ HTTP API
               │ DLL Adapter
               │ یا TCP Socket
               ▼
┌──────────────────────────────┐
│            mYPMS             │
│                              │
│ Parking Management Software  │
│                              │
│ وظایف:                       │
│                              │
│ - UI                         │
│ - Vehicle Records            │
│ - Access Control             │
│ - Parking Logic              │
│ - Reports                    │
│ - Operator Panel             │
│ - Database                   │
└──────────────┬───────────────┘
               │
               │ GPIO / Relay
               │ Serial / TCP
               ▼
┌──────────────────────────────┐
│         Barrier Gate         │
│                              │
│  راهبند پارکینگ              │
└──────────────────────────────┘
```

---

# توضیح ارتباط‌ها

| مبدا | مقصد | نوع ارتباط |
|---|---|---|
| Camera | Node.js | RTSP Stream |
| Node.js | Python AI | HTTP REST / gRPC |
| Python AI | Node.js | JSON Response |
| Node.js | mYPMS | REST / DLL / TCP |
| mYPMS | Barrier | Relay / GPIO / Serial |
| Node.js | Browser Dashboard | WebSocket |
| Node.js | Redis Queue | TCP |
| Node.js | Database | SQL TCP Connection |

---

# ارتباط‌های واقعی پیشنهادی

## دوربین → Node.js

```text
RTSP
```

مثلاً:

```text
rtsp://192.168.1.10/live
```

ابزارها:

- ffmpeg
- gstreamer
- opencv
- node-rtsp-stream

---

# Node.js → Python AI

## بهترین انتخاب فعلی:

```text
HTTP REST
```

مثلاً:

```http
POST /recognize
Content-Type: multipart/form-data
```

ارسال:

- image
- camera_id
- timestamp

---

# پاسخ AI

```json
{
  "plate": "12ب34567",
  "confidence": 0.91,
  "bbox": [120,44,320,100]
}
```

---

# ارتباط Node.js → PMS

بسته به معماری PMS:

---

## حالت 1
### REST API

```text
Node.js → HTTP → PMS
```

---

## حالت 2
### DLL Adapter

```text
PMS → DLL → Node.js API
```

---

## حالت 3
### TCP Socket

```text
Node.js → TCP → PMS
```

---

# ارتباط راهبند

معمولاً:

- relay
- serial
- rs485
- tcp controller

---

# معماری ساده نهایی واقعی

```text
Camera
   │ RTSP
   ▼
Node.js
   │ HTTP/gRPC
   ▼
Python AI
   │ JSON
   ▼
Node.js
   │ API/Event
   ▼
mYPMS
   │ Relay/TCP
   ▼
Barrier Gate
```

---

# نقش واقعی هر بخش

| بخش | وظیفه |
|---|---|
| Camera | تولید تصویر |
| Node.js | مدیریت سیستم |
| Python AI | تشخیص پلاک |
| mYPMS | منطق پارکینگ |
| Barrier | کنترل فیزیکی |

---

# چیزی که تو واقعاً می‌سازی

تو بیشتر داری این را می‌سازی:

```text
Realtime Distributed Video Processing System
```

نه صرفاً:

```text
YOLO Project
```

چون بخش سخت production معمولاً این‌ها هستند:

- reconnect دوربین
- queue overload
- duplicate events
- unstable streams
- async timing
- memory leaks
- retry logic
- deployment

نه خود مدل AI.

مدل معمولاً آرام‌ترین عضو تیم است. دوربین‌های RTSP برعکس، مثل موجوداتی هستند که هر زمان احساساتشان جریحه‌دار شود disconnect می‌شوند.
