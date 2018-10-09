#!/bin/sh
#
#
# �ظm�b����{���θ���ɮ׬����v�����ˬd�\�श���A��b���M�d�@�~�ɤ@�֦C�ܲM�d
# �ϥΫe�Х��w�q �H�U�Ѽ�
# DIRECTORY_YOU_WANT_TO_CHECK_PERMISSION  #���y�o�ǥؿ��U�Ҧ��ɮ׻P�ؿ����v��

DIRECTORY_YOU_WANT_TO_CHECK="/home"

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
       �D�t�αb����~�ȵ{���θ���ɮפ������v���d��
       Hostname: $(hostname), Today is $(date +%Y-%m-%d)
  +====================================================================+

      1. ����b���v���ˬd�C�N���G�g�J ACCESS_report_$(hostname)_$(date +%Y%m%d).txt
      2. �C�X���浲�G

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

      if ! [[ $_readable = "" && $_writable = "" && $_execable="" ]]; then
        printf "%-8s %-4s %-5s %-4s %-s \n" $id "$_readable" "$_writable" "$_execable" "$_dir" >>$ACCESS_REPORT
      fi

      sub_dirs=$(ls -la $_dir | grep "^d" | awk '{print $NF}' | grep -v "^\.")
      for sub_dir in $sub_dirs; do
        _readable=""
        _writable=""
        _execable=""
        su $id -c "test -r '$_dir/$sub_dir'" >/dev/null 2>&1 && _readable="read"
        su $id -c "test -w '$_dir/$sub_dir'" >/dev/null 2>&1 && _writable="write"
        su $id -c "test -x '$_dir/$sub_dir'" >/dev/null 2>&1 && _execable="exec"
        if ! [[ $_readable = "" && $_writable = "" && $_execable="" ]]; then
          printf "%-8s %-4s %-5s %-4s %-s \n" $id "$_readable" "$_writable" "$_execable" "$_dir/$sub_dir" >>$ACCESS_REPORT
        fi
      done
    done
  done
}

list_last_ACCESS_REPORT() {
  if [ -f $ACCESS_REPORT ]; then
    cat $ACCESS_REPORT
    return
  else
    echo "�S�����Ѫ����i�C"
    return
  fi

  reports=$(ls -tr ACCESS_*)

  if [ -z "${reports}" ]; then
    echo "�����͹L���i�A�а���ﶵ 1�C"
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
