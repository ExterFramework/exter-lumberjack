# exter-lumberjack (Refactored)

Script pekerjaan **lumberjack** untuk FiveM dengan pendekatan modular, validasi data yang lebih ketat, dan kompatibilitas lintas framework.

## Fitur Utama

- Kompatibel dengan framework:
  - **QBCore**
  - **Qbox (qbx_core)**
  - **ESX**
  - **Standalone** (degradasi fitur yang aman)
- Kompatibel dengan inventory:
  - **ox_inventory**
  - **qb-inventory**
  - **qs-inventory** (fallback berbasis framework)
  - **esx_inventory / esx_inventoryhud**
  - **standalone fallback**
- Kompatibel fuel system:
  - **LegacyFuel**
  - **CDN-Fuel**
  - **ox_fuel**
  - **qb-fuel**
  - `none` (tanpa fuel integration)
- Sistem produksi item berantai:
  1. `log`
  2. `cleanlog`
  3. `rawplank`
  4. `sandedplank`
  5. `finishwood`
- Error handling dan rollback transaksi item (jika gagal add/remove item, item dikembalikan).
- Dukungan notifikasi sesuai framework.

---

## Instalasi

1. Pindahkan folder resource ke server Anda:
   - `resources/[jobs]/exter-lumberjack`
2. Pastikan dependency aktif:
   - `ox_lib`
   - `interact`
3. Tambahkan ke `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure interact
   ensure exter-lumberjack
   ```
4. Tambahkan item ke framework/inventory Anda (lihat panduan item di bawah).
5. Restart resource:
   ```cfg
   restart exter-lumberjack
   ```

---

## Konfigurasi

Semua konfigurasi ada di `shared/config.lua`.

### Opsi penting

- `Config.Framework = 'auto'`
  - Auto-detect: qbox → qbcore → esx → standalone.
- `Config.Inventory = 'auto'`
  - Auto-detect: ox_inventory → qb-inventory → qs-inventory → esx_inventory.
- `Config.FuelSystem = 'auto'`
  - Auto-detect: ox_fuel → LegacyFuel → CDN-Fuel → qb-fuel.
- `Config.Items`
  - Mapping nama item yang dipakai script.
- `Config.logPerChop`, `Config.planksPerLog`, `Config.woodPrice`
  - Balancing ekonomi dan progression.

---

## Cara Pakai

1. Sign in job melalui contact/NPC Anda.
2. Ambil/siapkan axe.
3. Tebang pohon (swing pertama untuk merobohkan, berikutnya untuk mendapatkan log).
4. Proses item di titik interaksi:
   - Log → Clean Log
   - Clean Log → Raw Plank
   - Raw Plank → Sanded Plank
   - Sanded Plank → Finish Wood
5. Jual `finishwood` untuk mendapatkan uang.

---

## Panduan Menambahkan Item

> Gunakan nama item yang sama seperti `Config.Items`, atau ubah mapping di `shared/config.lua`.

### 1) QBCore (qb-core + qb-inventory)

Tambahkan di `qb-core/shared/items.lua`:

```lua
['axe'] = {
    ['name'] = 'axe',
    ['label'] = 'Axe',
    ['weight'] = 500,
    ['type'] = 'item',
    ['image'] = 'np_axe.png',
    ['unique'] = true,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['description'] = 'A sharp axe.'
},
['log'] = {
    ['name'] = 'log',
    ['label'] = 'Log',
    ['weight'] = 500,
    ['type'] = 'item',
    ['image'] = 'np_log.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = true,
    ['description'] = 'Fresh cut wood log.'
},
['cleanlog'] = {
    ['name'] = 'cleanlog',
    ['label'] = 'Clean Log',
    ['weight'] = 500,
    ['type'] = 'item',
    ['image'] = 'np_log.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = true,
    ['description'] = 'Processed clean log.'
},
['rawplank'] = {
    ['name'] = 'rawplank',
    ['label'] = 'Raw Wooden Plank',
    ['weight'] = 500,
    ['type'] = 'item',
    ['image'] = 'np_wood.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = true,
    ['description'] = 'Rough wood plank.'
},
['sandedplank'] = {
    ['name'] = 'sandedplank',
    ['label'] = 'Sanded Wooden Plank',
    ['weight'] = 500,
    ['type'] = 'item',
    ['image'] = 'np_wood.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = true,
    ['description'] = 'Sanded ready plank.'
},
['finishwood'] = {
    ['name'] = 'finishwood',
    ['label'] = 'Finished Wood',
    ['weight'] = 500,
    ['type'] = 'item',
    ['image'] = 'np_wood.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = true,
    ['description'] = 'Finished wood product.'
},
```

### 2) Qbox

Qbox umumnya menggunakan struktur item yang kompatibel dengan style QBCore. Tambahkan item pada file item qbox Anda sesuai format server (umumnya setara dengan contoh QBCore di atas).

### 3) ESX

Tambahkan item pada database/items sesuai sistem ESX server Anda:

```sql
INSERT INTO items (name, label, weight) VALUES
('axe', 'Axe', 500),
('log', 'Log', 500),
('cleanlog', 'Clean Log', 500),
('rawplank', 'Raw Wooden Plank', 500),
('sandedplank', 'Sanded Wooden Plank', 500),
('finishwood', 'Finished Wood', 500);
```

### 4) ox_inventory

Tambahkan ke `ox_inventory/data/items.lua`:

```lua
['axe'] = { label = 'Axe', weight = 500, stack = false, close = true },
['log'] = { label = 'Log', weight = 500 },
['cleanlog'] = { label = 'Clean Log', weight = 500 },
['rawplank'] = { label = 'Raw Wooden Plank', weight = 500 },
['sandedplank'] = { label = 'Sanded Wooden Plank', weight = 500 },
['finishwood'] = { label = 'Finished Wood', weight = 500 },
```

### 5) qs-inventory

Tambahkan item pada file item qs-inventory Anda sesuai struktur server Anda. Gunakan nama item yang sama.

### 6) Inventory Lainnya

Selama framework menyediakan fungsi add/remove/get item yang kompatibel, Anda bisa:
- set `Config.Inventory = 'auto'` dan biarkan fallback,
- atau hard set ke mode yang paling mendekati (`qb-inventory` / `esx_inventory` / `ox_inventory`).

---

## Catatan Integrasi Fuel

Untuk kendaraan kerja, script otomatis mencoba integrasi fuel sesuai resource yang aktif.
Jika ingin memaksa mode tertentu, ubah:

```lua
Config.FuelSystem = 'legacyfuel' -- contoh
```

Opsi valid:
- `auto`
- `legacyfuel`
- `cdn-fuel`
- `ox_fuel`
- `qb-fuel`
- `none`

---

## Troubleshooting

- **Tidak dapat chop / process item**
  - Cek item sudah ditambahkan dengan benar.
  - Pastikan nama item sama dengan mapping `Config.Items`.
- **Notifikasi tidak muncul**
  - Pastikan framework terdeteksi benar atau set manual `Config.Framework`.
- **Fuel tidak terpasang**
  - Pastikan resource fuel menyala dan `Config.FuelSystem` tidak salah ketik.
- **Interaksi tidak muncul**
  - Pastikan dependency `interact` aktif.

---

## Pengujian yang Disarankan (Server Anda)

- Tebang pohon berulang dan pastikan tidak terjadi freeze.
- Uji inventory penuh saat proses item.
- Uji rollback saat add item gagal.
- Uji jual item dengan jumlah besar.
- Uji setiap kombinasi framework + inventory + fuel yang digunakan server Anda.

