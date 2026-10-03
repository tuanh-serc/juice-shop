# Quy trình nhóm
1. Mỗi nhóm fork juice-shop về GitHub của nhóm, bật bảo vệ nhánh `main` (Settings > Branches).
2. `cd lab && docker compose up -d db sonarqube`, mở http://localhost:9000 (admin/admin, đổi mật khẩu).
3. Tạo token, `export SONAR_TOKEN=...`
4. Mỗi thành viên: `git checkout lab-setup && git checkout -b findings/<ten>`
5. `./lab/scan.sh` -> lấy báo cáo trong `reports/`
6. Ghi lỗi vào `docs/FINDINGS.md`, commit lên nhánh của mình, mở Pull Request vào `lab-setup`.
7. (Tùy chọn, cho lỗi logic/cấu hình) chạy app: `docker run --rm -p 3000:3000 bkimminich/juice-shop`
