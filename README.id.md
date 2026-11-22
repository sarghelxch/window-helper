# Window Helper

[English](README.md) | **Bahasa Indonesia**

![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-blue)
![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0%2B-green)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

Script AutoHotkey v2 untuk **resize, center, dan memindahkan window antar monitor** di Windows 10/11 — tanpa window "kabur" kembali ke monitor primary.

> _Terjemahan ini mungkin tertinggal dari [versi Inggris](README.md)._

---

## Kenapa script ini dibuat

Sebagian besar snippet resize/center AutoHotkey menghitung posisi window menggunakan `A_ScreenWidth` dan `A_ScreenHeight`. Di AutoHotkey, kedua nilai itu **selalu mengacu ke monitor primer**, di mana pun window berada. Karena `WinMove` memakai koordinat absolut virtual desktop (dengan `(0,0)` di pojok kiri-atas monitor primer), hasilnya window "tertarik" kembali ke layar utama.

Script ini memperbaikinya dengan:

- Mendeteksi **monitor tempat window berada** (berdasarkan titik tengahnya).
- Menghitung ukuran dan posisi relatif terhadap **work area monitor tersebut** (taskbar tidak ikut dihitung).
- Tidak lagi bergantung pada resolusi monitor primer.

---

## Fitur

- Resize dan center window aktif di monitor tempat ia berada.
- Pindah window ke monitor berikutnya, atau langsung ke nomor monitor tertentu.
- Pindah window berdasarkan arah fisik (kiri/kanan), sehingga tetap benar walau penomoran monitor Windows tidak sesuai tata letak fisik.
- Menghormati work area monitor, jadi window tidak tertutup taskbar.
- Menangani window maximized/fullscreen dengan benar.
- Otomatis mengecilkan window secara proporsional jika lebih besar dari monitor tujuan.
- Mengoreksi posisi akhir ketika aplikasi membatasi ukuran minimum window.

---

## Persyaratan

| Kebutuhan | Keterangan |
|---|---|
| OS | Windows 10 / Windows 11 |
| AutoHotkey | **v2.0 atau lebih baru** (tidak kompatibel dengan v1) |
| Monitor | 1 monitor untuk fitur resize; **2+ monitor** untuk fitur pindah |

---

## Instalasi

1. Install [AutoHotkey v2](https://www.autohotkey.com/) jika belum ada.
2. Simpan script sebagai `window-helper.ahk` (encoding UTF-8).
3. Klik dua kali file tersebut untuk menjalankan. Ikon AHK akan muncul di system tray.
4. (Opsional) Agar berjalan otomatis saat login:
   - Tekan `Win + R`, ketik `shell:startup`, lalu Enter.
   - Taruh **shortcut** `window-helper.ahk` di folder yang terbuka.

Untuk menghentikan script: klik kanan ikon AHK di tray → **Exit**.

---

## Penggunaan

| Shortcut | Fungsi |
|---|---|
| `Ctrl + Alt + R` | Resize & center window di monitor tempat ia berada |
| `Ctrl + Alt + M` | Pindah window ke monitor berikutnya (berputar 1 → 2 → … → n → 1) |
| `Ctrl + Alt + 1` | Pindah window ke monitor 1 |
| `Ctrl + Alt + 2` | Pindah window ke monitor 2 |
| `Ctrl + Alt + ←` | Pindah ke monitor yang secara fisik berada di kiri |
| `Ctrl + Alt + →` | Pindah ke monitor yang secara fisik berada di kanan |

Catatan perilaku:

- `Ctrl + Alt + R` pada window fullscreen akan mengembalikannya menjadi window normal yang sudah di-resize.
- `Ctrl + Alt + M` dan `Ctrl + Alt + 2` **mempertahankan status fullscreen**: window di-restore, dipindah, lalu di-maximize lagi di monitor tujuan.
- Ukuran window dipertahankan saat dipindah, kecuali jika window lebih besar dari monitor tujuan (akan dikecilkan proporsional).

---

## Cara kerja

```
Ctrl+Alt+R  →  GetWindowMonitor()  →  MonitorGetWorkArea()  →  hitung ukuran & center  →  WinMove()
Ctrl+Alt+M  →  GetWindowMonitor()  →  monitor berikutnya    →  MoveToMonitor()
Ctrl+Alt+←/→ →  GetWindowMonitor()  →  monitor terdekat di arah tsb  →  MoveToMonitor()
```

| Fungsi | Tugas |
|---|---|
| `ResizeCenter()` | Mengubah ukuran window ke persentase dari work area monitor aktif, lalu memusatkannya. |
| `MoveToNextMonitor()` | Menentukan monitor tujuan berikutnya secara berurutan. |
| `MoveToMonitor(index)` | Memindahkan window ke nomor monitor tertentu dan memusatkannya. |
| `MoveDirectional(dir)` | Memilih monitor tujuan berdasarkan posisi fisik (kiri/kanan). |
| `GetWindowMonitor(hwnd)` | Mengembalikan indeks monitor yang memuat titik tengah window. |

---

## Konfigurasi

Semua pengaturan ada di dalam fungsi `ResizeCenter()`.

### Mengubah persentase ukuran

```ahk
; monitor lebar (> 2560 px) → 85%, selain itu 90%
newW := Round(areaW * (areaW > 2560 ? 0.85 : 0.90))
newH := Round(areaH * 0.90)
```

Contoh: ingin selalu 80% lebar dan 85% tinggi:

```ahk
newW := Round(areaW * 0.80)
newH := Round(areaH * 0.85)
```

### Mengubah ambang "monitor lebar"

Sesuaikan angka `2560` dengan resolusi monitor Anda (mis. `1920` untuk FHD, `3840` untuk 4K).

### Menambah hotkey untuk monitor ke-3 dan seterusnya

Tambahkan di bagian atas script, di antara daftar hotkey:

```ahk
^!3::MoveToMonitor(3)
^!4::MoveToMonitor(4)
```

---

## Troubleshooting

**Window tidak mau berpindah atau berubah ukuran**
Aplikasi target mungkin berjalan dengan hak administrator. Jalankan AutoHotkey *as administrator* (klik kanan → Run as administrator), atau jalankan script lewat Task Scheduler dengan opsi "Run with highest privileges".

**Posisi meleset beberapa piksel di setup multi-monitor dengan skala berbeda**
Biasanya karena perbedaan DPI antar monitor (mis. laptop 150% + monitor 100%). Coba tambahkan baris berikut di paling atas script, sebelum hotkey apa pun:

```ahk
DllCall("SetProcessDpiAwarenessContext", "Ptr", -4)
```

**Aplikasi UWP / Microsoft Store tidak bisa dipindah**
Beberapa aplikasi UWP membatasi pengaturan posisi window oleh program lain. Ini batasan Windows, bukan bug script.

**Hotkey tidak berfungsi**
Kemungkinan bentrok dengan aplikasi lain yang memakai kombinasi yang sama. Ubah kombinasi di bagian atas script, misalnya `^!R` menjadi `^!+R`.

**Muncul error saat menjalankan**
Pastikan AutoHotkey yang terpasang adalah **v2**, bukan v1. Script ini memakai sintaks v2 (mis. `WinMove(x, y, w, h, "A")`), yang tidak akan jalan di v1.

**Window kembali ke posisi lama setelah dipindah**
Beberapa aplikasi menyimpan dan memulihkan posisi window-nya sendiri. Coba pindahkan dalam keadaan window normal (bukan minimized).

---

## Alternatif

Windows 10/11 sudah menyediakan `Win + Shift + ←/→` untuk memindahkan window antar monitor. Script ini berguna jika Anda juga ingin **resize + center** serta kontrol yang lebih presisi, yang tidak disediakan shortcut bawaan.

---

## Kontribusi

Issue dan pull request dipersilakan. Jika melaporkan bug, sertakan versi Windows, versi AutoHotkey, dan tata letak monitor (resolusi + skala).

---

## Lisensi

Dirilis di bawah [MIT License](LICENSE).
