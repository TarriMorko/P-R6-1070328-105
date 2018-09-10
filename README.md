# P-R6-1070328-105
## Changelog

## [Unreleased]
1.  AIX 有 suid 的部分，在比對檔案權限時有問題(多一個 suid欄位)
2. 產生檔案與目錄權限基準檔 但是要by帳號


## [0.8.5] - 2018-09-10
### fixed
- 排除 itmadm@10.0.31.235

## [0.8.4] - 2018-09-05
### fixed
- 裡面英文都改中文
- AIX 的 find 沒有 maxdepth 選項，已修正
- 移動相關參數到最前端

## [0.8.3] - 2018-09-04
### fixed
 - 選項5. AIX 用 rlogin=True 的帳號，Linux 用 sshd 裡面的 AllowUsers 帳號
 - 選項5. 改為出到 ACCESS_report 文字檔


## [0.8.2] - 2018-09-03
### fixed
 - 選項5. 改為列出指定目錄與其下一層目錄


## [0.8.1] - 2018-08-28
### fixed
 - 修改選項「1. 檢查檔案與目錄權限」 將輸出格式化
 - 修改選項「2. 檢查檔案 hash」    將輸出格式化
 - 修改選項「5. 列出某帳號可以讀取、寫入、執行、哪些目錄」  將帳號指定為可 ssh 登入的帳號


## [0.8] - 2018-08-10
### fixed
 - 保留 1, 2, 3, 4, 11 項功能
 - 選項「列出某帳號可以讀取、寫入、執行、哪些目錄」從11. 改為 5. 其餘刪除


## [0.7.5] - 2018-07-27
### Added
 - 12. 列出某帳號可以讀取、寫入、執行、哪些目錄以及其子目錄


## [0.7] - 2018-07-27
### Added
 - 11. 列出某帳號可以讀取、寫入、執行、哪些目錄


## [0.6] - 2018-07-26
### Added
 - 8. 列出某帳號可以讀取哪些目錄
 - 9. 列出某帳號可以寫入哪些目錄
 - 10. 列出某帳號可以執行哪些目錄


## [0.5] - 2018-07-25
### Added
 - 指定一或多個目錄，列出哪些帳號具有該目錄的「讀取」權限
 - 指定一或多個目錄，列出哪些帳號具有該目錄的「寫入」權限
 - 指定一或多個目錄，列出哪些帳號具有該目錄的「執行」權限
### Fixed
 - 檢查檔案權限 改為 檢查檔案及目錄權限
 - 產生檔案權限基準檔 改為 產生檔案及目錄權限基準檔
 - 移除查「某個帳號」在「某個目錄」下、同時「讀取、寫入、執行」權限的所有目錄
 - 移除查「某個帳號」在「某個目錄」下、有讀取/寫入/執行權限的所有目錄

## [0.4] - 2018-06-05
### Added
 - 增加功能8, 查「某個帳號」在「某個目錄」下、同時「讀取、寫入、執行」權限的所有目錄
 - 增加三個 func, 查「某個帳號」在「某個目錄」下、有讀取/寫入/執行權限的所有目錄

## [0.3] - 2018-05-16
### Fixed
 - 修正 linux 的部分，已在 SuSE12sp1, Centos7.4 測試過.
 - AIX 的部分測試完了.

## [0.2] - 2018-05-11
### Fixed
 - 修正 check_permission_and_md5 的AIX istat換行.

## [0.1] - 2018-05-07
### Added
 - First audit release.
 - 1. 檢查檔案權限
 - 2. 檢查檔案 hash
 - 3. 產生檔案權限基準檔      
 - 4. 產生檔案 hash 基準檔
 - User story.