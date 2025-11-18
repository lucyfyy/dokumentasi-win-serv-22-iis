# Rollout Server Production JBT (Windows Server 2022)
## Pre-requirements
1. Postgresql 16.11 [Download Here](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads)
2. PHP 8.3 [Download Here](https://www.php.net/downloads.php?usage=web&os=windows&osvariant=windows-downloads&version=8.3)
3. IIS (Internet Information Services)
4. Git [Download Here](https://git-scm.com/install/windows)
5. Composer [Download Here](https://getcomposer.org/download/)
6. File backup database yang dibackup menggunakan command berikut
```
pg_dump -U postgres -Fc -f relaypro.dump relaypro
```

## Installation
### Postgresql
1. Cari `.exe` file yang sudah didownload tadi. Kemudian jalankan.
2. Tinggal klik `Next`. Kemudian untuk `Components` bisa uncheck yang tidak dibutuhkan.
3. `Next`. Kemudian bisa ditambahkan `Password`. Akan lebih baik jika password randomize. Contoh pakai [Bitwarden Password Generator](https://bitwarden.com/password-generator/#password-generator).
4. Kemudian `Next`, pilih `locale` jika perlu. Kemudian tinggal `Next` `Next` `Next`.
5. Klik `Install`.
6. Tunggu sampai proses penginstallan selesai.
7. Uncheck `postgre builder` jika tidak dibutuhkan (agar hemat waktu).
8. Klik `Finish`.
9. Masuk ke direktori `C:\Program Files\PostgreSQL\16\data` dan edit `pg_hba.conf`. Ubah barisan-barisan paling bawah diganti yang `local` dari `scram-sha-256` ke `trust`.
10. Membuat database baru dengan nama `relaypro`.
11. Melakukan upload file `.sql` menggunakan command berikut.
```
pg_restore -U postgres -d relaypro relaypro.dump
```

### PHP 8.3
1. Cari `.zip` file yang sudah didownload tadi. Kemudian buat direktori di `C:\`
2. Ekstract file `.zip` ke dalam direktori tersebut.
3. Tambahkan direktori ke environment variable.
4. Buka cmd dan test apakah command `php` sudah bisa dipakai.
5. Lanjut copy file `php.ini-production` ke `php.ini`.
6. Kemudian enable `pdo_pgsql`, `pgsql`, serta ekstensi yang lain. Berikut list opsional:
    1. `mbstring`
    2. `openssl`
    3. `curl`
    4. `json`
    5. `intl`
    6. `fileinfo`
    7. `gd`
    8. `zip`
7. Atau jika ada konfigurasi lainnya. Seperti:
    1. `upload_max_filesize = 20M`
    2. `post_max_size = 20M`
    3. `max_execution_time = 60`
    4. `date.timezone = "Asia/Jakarta"`
    5. `log_errors = On`
    6. `error_log = /var/log/php_errors.log`
    7. `display_errors = Off`
8. Kalau sudah di save.

### IIS (Internet Information Services)
1. Buka `Server Manager`.
2. Klik `2. Add Roles and Features`. Akan muncul window baru.
3. Kemudian tinggal `Next` saja.
4. `Instalation Type` pilih yang pertama.
5. `Server Selection` pilih server from server pool yang akan diinstall IIS.
6. `Server Roles` checklist `Web Server (IIS)`. Kemudian baca sedikit, dan klik `Add features`. Dan `Next`.
7. Bagian `Features` dapat langsung diskip/`Next` saja.
8. Bagian `Web Server Role (ISS)` juga skip.
9. `Role Service` bisa di ceklist bagian `Application Development` dan ceklist `CGI`.
10. Kemudian tinggal klik `install` dan tunggu sampai selesai.

### Git
1. Buka file `.exe` yang sudah didownload.
2. `Next`, `Next`, pada `Select Components` bisa disesuaikan dengan kebutuhan. Jika sudah `Next`.
3. Untuk `default editor` saya pilih notepad, jika memiliki vscode bisa pakai vscode. Atau yang lain juga bisa.
4. Kemudian `Next` `Next` saja. Untuk `ssh` pakai yang `bundled` dari git.
5. `Next` `Next` lagi. Saat memilih terminal bisa menggunakan `windows default console`.
6. `Next` `Next` lagi. Dan `Install`.

### Composer
1. Buka file `.exe` yang sudah didownload.
2. Pilih mau install di user ini saja atau all user.
3. Kemudian `Next` dan pilih php file executable path-nya.
4. Tinggal `Next` `Next` dan `Install`.

### Source Code
1. Pull source code
2. Buat file `web.config` pada direktori `root folder\web`
```
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <directoryBrowse enabled="false" />
    <defaultDocument>
      <files>
        <add value="index.php" />
      </files>
    </defaultDocument>
    <rewrite>
      <rules>
        <rule name="Yii2 Rewrite" stopProcessing="true">
          <match url="^(.*)$" ignoreCase="false" />
          <conditions logicalGrouping="MatchAll">
            <add input="{REQUEST_FILENAME}" matchType="IsFile" ignoreCase="false" negate="true" />
            <add input="{REQUEST_FILENAME}" matchType="IsDirectory" ignoreCase="false" negate="true" />
          </conditions>
          <action type="Rewrite" url="index.php/{R:1}" appendQueryString="true" />
        </rule>
      </rules>
    </rewrite>
    <handlers>
      <add name="PHP-FastCGI" path="*.php" verb="*" modules="FastCgiModule" scriptProcessor="C:\php\php-cgi.exe" resourceType="File" requireAccess="Script" />
    </handlers>
  </system.webServer>
</configuration>
```
3. mkdir bbrp file tersebut dalam direktori `web`.
    1. `assets`
    2. `uploads`
    3. `uploads\signature`
4. mkdir `runtime` dalam direktori `root`.
5. Allow user `IIS` untuk dapat `write` folder folder tersebut.
6. Setup `root\config\db.php`. Gunakan `localhost` untuk `host`nya.

## Konfigurasi IIS (Internet Information Services)
### Add module Fast CGI
1. Kemudian bisa klik `Server Root` nya dan klik `Handler Mappings`.
2. Klik `Add Module Mapping` pada list `Action` pojok kanan atas.
3. Untuk `Request path` bisa ditambahkan `*.php`.
4. `Module` bisa pilih `FastCgiModule`.
5. Untuk executable filenya bisa pilih `fast-cgi.exe` pada direktori `C:\Php8.3` tadi.
6. Nama bisa ditambahkan `FastCGI`.
7. Klik `Request Restrictions...`
    1. Pada `Mapping` bisa pilih `File or Folder`.
8. Kemudian tinggal di `OK` saja.

### Tambahkan web yang akan dideploy
1. Stop `Default Web Site` pada `Site`.
2. Pada `Site` bisa klik `Add Website...`
    1. `Site name` bisa ditambahkan nama aplikasi.
    2. `Physical path` bisa ditambakan folder root aplikasi.
    3. `Hostname` bisa ditambahkan nama domain yang akan dipakai.
    4. Kemudian tinggal `OK`.
3. Tambahkan `index.php` ke `Default Document`. (Opsional) yang lain bisa diremove.
4. Selanjutnya bisa copy file `index.php` kedalam direktori `C:\inetpub\wwwroot`. Untuk isinya dapat dibackup terlebih dahulu atau langsung dihapus saja.

## Setup Firewall and Security
### Disable all port
Menggunakan script `block_all_inbound_firewall.ps1`

### Allow port
Menggunakan command dibawah ini dengan Powershell untuk port 80. Port lain tinggal menyesuaikan.
```
New-NetFirewallRule -DisplayName "Allow HTTP 80" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow
```

### Restore default konfigurasi firewall
Menggunakan script `restore_firewall.ps1`

### Disable TRACE Method
1. Install [URL_Rewrite Module](https://www.iis.net/downloads/microsoft/url-rewrite) (Tinggal `Next` `Next` saja).
2. Copy config ini untuk `web.config` (Adjust sesuai kebutuhan).
```
<configuration>
  <system.webServer>
    
    <security>
      <requestFiltering>
        <verbs applyToWebDAV="false">
          <add verb="TRACE" allowed="false" />
          <add verb="OPTIONS" allowed="false" />
          <add verb="PUT" allowed="false" />
          <add verb="DELETE" allowed="false" />
        </verbs>
      </requestFiltering>
    </security>

  </system.webServer>
</configuration>
```
3. Restart IIS menggunakan command ini di Powershell
```
iisreset
```
4. Selesai