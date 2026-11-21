# NeloOS

**Hệ điều hành Linux cho máy tính cá nhân.**

[English](README.md)

NeloOS dựa trên [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/)
(KDE Plasma, bản atomic) và được đóng gói thành một container image boot được bằng
[bootc](https://bootc-dev.github.io/bootc/).

Tên Nelo lấy từ *Nelumbo*, tên khoa học của chi sen.

> Trạng thái: **Alpha**. Dự án đang ở giai đoạn dựng nền, chưa dùng được cho máy làm việc.

## Có gì trong bản hiện tại

- KDE Plasma trên Fedora 45, cập nhật nguyên khối (atomic), lỗi thì quay lại bản cũ được.
- Bộ gõ tiếng Việt fcitx5 + Unikey bật sẵn trên Wayland (Ctrl+Space để chuyển Anh/Việt).
- Gói ngôn ngữ tiếng Việt, font tương thích Office (Carlito, Caladea, Liberation).
- Mặc định giao diện tiếng Việt và giờ Việt Nam (chọn lại được lúc cài).
- Giao diện NeloOS: bảng màu xanh ngọc, font Be Vietnam Pro, taskbar kiểu Windows
  (nút Start, ứng dụng ghim, khay hệ thống, đồng hồ).
- Flathub bật sẵn trong Discover.
- Branding NeloOS: tên hệ điều hành, logo, hình nền, màn hình khóa.

## Build và chạy thử

Tài liệu cho lập trình viên viết bằng tiếng Anh: [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

Tóm tắt:

```bash
sudo dnf install podman qemu-kvm edk2-ovmf make
make qcow2     # build image và tạo ổ đĩa máy ảo
make run-vm    # khởi động NeloOS trong máy ảo (đăng nhập: nelo / nelo)
```

## Cập nhật trên máy đã cài

```bash
sudo bootc upgrade     # tải bản mới, áp dụng ở lần khởi động sau
sudo bootc rollback    # quay về bản trước nếu có lỗi
```

## Đóng góp

Mọi người đều có thể đóng góp. Code, comment, commit message và tài liệu kỹ thuật viết
bằng tiếng Anh để lập trình viên khắp nơi cùng tham gia. Những gì người dùng nhìn thấy
(giao diện, tài liệu hướng dẫn, website) ưu tiên tiếng Việt.

## License và thương hiệu

- Mã nguồn: [Apache-2.0](LICENSE). Các ngoại lệ ghi trong [NOTICE](NOTICE).
- Logo, hình nền: CC-BY-SA-4.0, xem [branding/README.md](branding/README.md).
- Tên và logo NeloOS: xem [TRADEMARKS.md](TRADEMARKS.md). Bản phái sinh phát hành lại
  cần đổi tên và logo.

NeloOS là một bản phái sinh (remix) độc lập của Fedora, không được Fedora Project
bảo trợ hay xác nhận. Fedora là nhãn hiệu của Red Hat, Inc.
