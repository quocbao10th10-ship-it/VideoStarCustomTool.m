# VIDEO STAR CUSTOM TOOL (BẢN TỰ DO - KHÔNG CẦN KEY)

Dự án Tweak iOS (`.dylib`) sạch 100%, **hoạt động hoàn toàn ngoại tuyến (offline)**, không cần Key kích hoạt, không cần Server mạng.

---

## 1. Các tính năng tích hợp sẵn
* **Nút tròn nổi kéo thả (`⭐`):**
  * Nổi trên màn hình Video Star, kéo thả tự do, tự động hít vào mép viền.
  * Nhận diện cảm ứng thông minh: Chỉ bắt chạm khi bấm vào nút; các thao tác khác xuyên thẳng xuống Video Star bình thường.
* **Nạp Preset từ Album ảnh (QR Code Reader):**
  * Mở trực tiếp thư viện ảnh iPhone (`Photos Library`).
  * Quét và trích xuất thông số Preset từ mã QR bằng bộ xử lý `CIDetector` của iOS.
* **Gộp phân đoạn tự động (Merge Scenes Helper):**
  * Hỗ trợ gộp cảnh nhanh chóng trong project.
* **KHÔNG CẦN KEY:** Mở app lên là sử dụng được ngay, không có bất kỳ popup hay giới hạn nào.

---

## 2. Cách biên dịch thành file `.dylib` (Miễn phí qua GitHub Actions)

1. Tạo một repository mới trên GitHub (để chế độ **Private**).
2. Tải toàn bộ thư mục `ios_tweak_project` này lên repo đó.
3. Vào tab **Actions** trên GitHub, chờ máy ảo macOS biên dịch trong khoảng 1 phút.
4. Tải file **`VideoStarCustomTool.dylib`** trong mục Artifacts về máy tính.

---

## 3. Cách chèn (Inject) vào file VideoStar.ipa

### Bằng Sideloadly (Trên máy tính Windows)
1. Mở **Sideloadly**.
2. Kéo file `VideoStar.ipa` vào Sideloadly.
3. Bấm **Advanced Options** -> phần **Inject dylibs/frameworks** bấm dấu `+` chọn file `VideoStarCustomTool.dylib`.
4. Bấm **Start** để cài đặt trực tiếp lên iPhone.

### Bằng ESign / Scarlet (Trực tiếp trên iPhone)
1. Mở **ESign** -> Import file `VideoStar.ipa`.
2. Chọn app -> Bấm **Signature (Ký)** -> Bấm **Add Dylib** -> Chọn `VideoStarCustomTool.dylib`.
3. Bấm ký và cài đặt.
