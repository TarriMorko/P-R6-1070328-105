#!/bin/sh
#
#
# 建置帳號對程式及資料檔案相關權限之檢查功能介面，於帳號清查作業時一併列示清查
# 使用前請先定義 以下參數
# DIRECTORY_YOU_WANT_TO_CHECK_PERMISSION  #掃描這些目錄下所有檔案與目錄的權限

DIRECTORY_YOU_WANT_TO_CHECK="/home/spos1 /home/spos2"

_HOME="/src/mwadmin/check_permission_and_md5"
ACCESS_REPORT="$_HOME/ACCESS_report_$(hostname)_$(date +%Y%m%d).txt"

if [[ "$(uname)" = "Linux" ]]; then
  OS="Linux"
else
  OS="AIX"
fi

show_main_menu() {
  # Just show main menu.
  clear
  cat <<EOF
  +====================================================================+
       Hostname: $(hostname), Today is $(date +%Y-%m-%d)
  +====================================================================+

      1. 執行帳號權限檢查。將結果寫入 ACCESS_report_$(hostname)_$(date +%Y%m%d).txt
      2. 列出執行結果

      q.QUIT

EOF
}

list_dirs_permissions_by_user() {
  # example
  # 
  # spos2    read       exec /home

  if [[ "$OS" = "Linux" ]]; then
    ids=$(grep "^AllowUsers" /etc/ssh/sshd_config | sed 's/AllowUsers//g' | sed 's/itmadm@10.0.31.235//g')
  else
    ids=$(lsuser ALL | grep rlogin=true | awk '{print $1}')
  fi

  if [[ -z "${ids}" ]]; then
    ids=$(cat /etc/passwd | awk -F':' '/.*sh$/  {print $1}')
  fi

  echo "Please wait..."
  echo HOSTNAME: $(hostname) "    " TIME: $(date +%Y/%m/%d) $(date +%H:%M:%S) >$ACCESS_REPORT

  for id in $ids; do
    for _dir in $DIRECTORY_YOU_WANT_TO_CHECK; do
      echo "===================================================================" >>$ACCESS_REPORT
      _readable=""
      _writable=""
      _execable=""
      su $id -c "test -r '$_dir'" >/dev/null 2>&1 && _readable="read"
      su $id -c "test -w '$_dir'" >/dev/null 2>&1 && _writable="write"
      su $id -c "test -x '$_dir'" >/dev/null 2>&1 && _execable="exec"
      printf "%-8s %-4s %-5s %-4s %-s \n" $id "$_readable" "$_writable" "$_execable" "$_dir" >>$ACCESS_REPORT

      sub_dirs=$(ls -la $_dir | grep "^d" | awk '{print $NF}' | grep -v "^\.")
      for sub_dir in $sub_dirs; do
        _readable=""
        _writable=""
        _execable=""
        su $id -c "test -r '$_dir/$sub_dir'" >/dev/null 2>&1 && _readable="read"
        su $id -c "test -w '$_dir/$sub_dir'" >/dev/null 2>&1 && _writable="write"
        su $id -c "test -x '$_dir/$sub_dir'" >/dev/null 2>&1 && _execable="exec"
        printf "%-8s %-4s %-5s %-4s %-s \n" $id "$_readable" "$_writable" "$_execable" "$_dir/$sub_dir" >>$ACCESS_REPORT
      done
    done
  done
}

list_last_ACCESS_REPORT() {
  if [ -f $ACCESS_REPORT ]; then
    cat $ACCESS_REPORT
  else
    echo "沒有今天的報告。"
    return
  fi

  reports=$(ls -tr ACCESS_*)

  if [ -z $reports ]; then
    echo "未產生過報告，請執行選項 1。"
    return
  fi

  last_report=$(ls -tr ACCESS_* | tail -1)
  cat $last_report

}

main() {
  # The entry for sub functions.
  while true; do
    cd ${_HOME}
    show_main_menu
    read choice
    clear
    case $choice in
    1) list_dirs_permissions_by_user ;;
    2) list_last_ACCESS_REPORT ;;
    [Qq])
      echo ''
      echo 'Thanks !! bye bye ^-^ !!!'
      echo ''
      exit
      logout
      ;;
    *)
      clear
      echo ''
      echo ' !!!  ERROR CHOICE , PRESS ENTER TO CONTINUE ... !!!'
      read choice
      ;;
    esac
    echo ''
    echo 'Press enter to continue' && read null
  done
}

main
