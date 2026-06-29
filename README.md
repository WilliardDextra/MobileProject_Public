===== FoodSaver =====

FoodSaver merupakan aplikasi berbasis E-Commerce yang berfokus melakukan penjualan makanan,
terkadang kita melihat bahwa mendekati closing time restaurant terdapat beberapa makanan yang terpaksa terbuang karena belum terjual
FoodSaver membantu menghubungkan Restaurant dengan Masyarakat yang ingin membeli makanan dengan harga lebih murah dan kualitas yang baik

Main Feature
Gamifikasi berupa Coins dan Voucher untuk meningkatkan retention dari pengguna aplikasi
Dan beberapa fitur E-Commerce pada umumnya seperti Filtering, Delivery/Pick up option, Food Categorize

Teknologi yang Digunakan
*   Mobile Frontend: Flutter (Dart) – Framework cross-platform untuk membangun antarmuka aplikasi Android dan iOS yang dinamis.
*   Backend API: node.js & Express.js – Runtime environment dan framework robust untuk menangani logika bisnis, RESTful API, dan autentikasi.
*   Database & Local Server: XAMPP (MySQL/Apache) – Digunakan sebagai environment database lokal untuk menyimpan data pengguna, makanan, dan transaksi.
*   Development Tools: 
    *   **Nodemon** – Utilitas untuk otomatis merestart server Node.js setiap kali ada perubahan kode.
    *   **ngrok** – Secure tunneling tool untuk menghubungkan backend lokal di laptop agar bisa diakses langsung oleh HP fisik/emulator secara real-time melalui internet.

Cara Menjalankan Aplikasi

Ikuti langkah-langkah berikut untuk menjalankan project FoodSaver di lingkungan lokal Anda:

#### Prasyarat (Prerequisites)
Sebelum memulai, pastikan Anda sudah menginstal:
*   Flutter SDK & Android Studio
*   Node.js & npm
*   XAMPP
*   ngrok CLI

#### Langkah A: Menjalankan Backend & Database
1.  Buka **XAMPP Control Panel**, lalu aktifkan module **Apache** (pastikan berjalan di port Anda, misal: `8080`) dan **MySQL**.
2.  Buka terminal/command prompt, lalu masuk ke folder backend Anda:
    ```bash
    cd E:\Flutter_Main_Project\BackEnd
    ```
3.  Jalankan server Node.js menggunakan Nodemon (secara default berjalan di port `3000`):
    ```bash
    npx nodemon index.js
    ```
4.  Buka terminal baru untuk mengaktifkan **ngrok** agar backend Anda bisa diakses oleh HP:
    ```bash
    ngrok http 3000
    ```
5.  Salin URL publik yang diberikan oleh ngrok (contoh: `https://xxxx-xxxx.ngrok-free.app`).

#### Langkah B: Menjalankan Frontend (Flutter)
1.  Buka project Flutter Anda menggunakan VS Code atau Android Studio.
2.  Cari file konfigurasi API (misal `api_config.dart` atau tempat Anda menyimpan variabel URL).
3.  Ubah `baseUrl` menjadi URL publik dari ngrok yang sudah Anda salin sebelumnya:
    ```dart
    String baseUrl = "[https://xxxx-xxxx.ngrok-free.app/api](https://xxxx-xxxx.ngrok-free.app/api)";
    ```
4.  Hubungkan HP Android/iOS Anda ke laptop menggunakan kabel USB (pastikan *USB Debugging* aktif).
5.  Jalankan perintah berikut di terminal project Flutter Anda untuk menginstal dan menjalankan aplikasi langsung ke HP:
    ```bash
    flutter run
    ```
6.  *(Opsional)* Jika Anda ingin membuat file mentahan aplikasi untuk dibagikan, jalankan:
    ```bash
    flutter build apk --release
    ```
    File APK hasil *build* dapat Anda temukan di direktori `build/app/outputs/flutter-apk/app-release.apk`.
