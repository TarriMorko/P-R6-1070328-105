#!/bin/sh
#
#
# please file these arg below
# DIRECTORY_YOU_WANT_TO_CHECK             # check who can access these dir
# DIRECTORY_YOU_WANT_TO_CHECK_PERMISSION  # scan file permission
# DIRECTORY_YOU_WANT_TO_CHECK_MD5         # scan file hash

DIRECTORY_YOU_WANT_TO_CHECK="/home /etc /src /"
DIRECTORY_YOU_WANT_TO_CHECK_PERMISSION="/etc"
DIRECTORY_YOU_WANT_TO_CHECK_MD5=$DIRECTORY_YOU_WANT_TO_CHECK_PERMISSION

_HOME="/src/mwadmin/check_permission_and_md5"

BASE_PERMISSION="$_HOME/BASE_PERMISSION"
PERMISSION_REPORT="$_HOME/PERMISSION_report_$(hostname)_$(date +%Y%m%d).txt"

BASE_MD5="$_HOME/BASE_MD5"
MD5_REPORT="$_HOME/MD5_report_$(hostname)_$(date +%Y%m%d).txt"

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

      1. Check file permission.
      2. check file hash.

      3. Create file permission baseline.
      4. Create file hash baseline.
      
      5. List account permission.

      q.QUIT

EOF
}

create_permission_today() {
  # create permission baseline today.
  # 
  # example:
  # /usr/bin/oldfind -rwxr-xr-x 0 0
  # /usr/bin/catchsegv -rwxr-xr-x 0 0
  # /usr/bin/xargs -rwxr-xr-x 0 0

  echo "Please wait..."
  _permission_today="$RANDOM"_temp
  for dir in $DIRECTORY_YOU_WANT_TO_CHECK_PERMISSION; do
    echo "Parsing $dir permission now..."
    echo ""
    if [[ $OS = "Linux" ]]; then

      for i in $(find $dir | grep -v -f exclude_file); do
        stat -c '%n %A %g %u' $i >>$_permission_today
      done

    else

      for i in $(find $dir | grep -v -f exclude_file); do
        echo $i" \c" >>$_permission_today
        istat $i | tr '\n' ' ' | awk '{print $8, $10, $12}' >>$_permission_today
      done

    fi

  done
}

diff_permission_today_with_BASE() {
  diff $BASE_PERMISSION $_permission_today >$PERMISSION_REPORT
  if [[ $? -eq 0 ]]; then
    echo ''
    echo "Permission Audit passed."
    echo "Permission Audit passed." >>$PERMISSION_REPORT

  else
    # echo ''
    # echo "Permission Audit failed. check $PERMISSION_REPORT for detail."
    # echo "Permission Audit failed." >>$PERMISSION_REPORT
    echo "Result:"
    echo "===================================================================="
    grep ">\|<" $PERMISSION_REPORT |
      awk '{print $NF}' |
      sort |
      uniq |
      xargs -I {} echo "These file has change its permission: {}"
    echo "===================================================================="
    echo "MD5 Audit failed."
    echo "check $PERMISSION_REPORT for detail."

  fi

  rm $_permission_today
}

check_permission() {
  create_permission_today
  diff_permission_today_with_BASE
}

create_md5_today() {
  # create hash baseline today.
  #
  # example:
  # 85bc0fd26b358ea8edc0d4cab5e92044  /usr/bin/oldfind
  # 795ad904fe7001acae1a149c4cd1ff3d  /usr/bin/catchsegv
  # 2098c131c6f1f63777e9678b4be4e752  /usr/bin/xargs

  _md5_today="$RANDOM"_temp

  for dir in $DIRECTORY_YOU_WANT_TO_CHECK_MD5; do
    echo "Parsing $dir hash now..."
    echo ""
    if [[ $OS = "Linux" ]]; then

      for i in $(find $dir -type f | grep -v -f exclude_file); do
        md5sum $i >>$_md5_today
      done

    else

      for i in $(find $dir -type f | grep -v -f exclude_file); do
        csum -h MD5 $i >>$_md5_today
      done

    fi
  done

}

diff_md5_today_with_BASE() {
  diff $BASE_MD5 $_md5_today >$MD5_REPORT

  if [[ $? -eq 0 ]]; then
    echo ""
    echo "MD5 Audit passed."
    # echo "MD5 Audit passed." >>$MD5_REPORT
  else
    echo "Result"
    echo "===================================================================="
    grep ">\|<" $MD5_REPORT |
      awk '{print $NF}' |
      sort |
      uniq |
      xargs -I {} echo "These file has change its permission: {}"
    echo "===================================================================="
    echo "MD5 Audit failed."
    echo "check $MD5_REPORT for detail."
  fi

  rm $_md5_today
}

check_md5() {
  create_md5_today
  diff_md5_today_with_BASE
}

create_base_permission() {
  # create permission baseline.
  # 
  # example:
  # /usr/bin/oldfind -rwxr-xr-x 0 0
  # /usr/bin/catchsegv -rwxr-xr-x 0 0
  # /usr/bin/xargs -rwxr-xr-x 0 0

  echo "Please wait..."
  rm $BASE_PERMISSION >/dev/null 2>&1
  for dir in $DIRECTORY_YOU_WANT_TO_CHECK_PERMISSION; do
    echo "Parsing $dir permission now..."
    echo ""
    if [[ $OS = "Linux" ]]; then

      for i in $(find $dir | grep -v -f exclude_file); do
        stat -c '%n %A %g %u' $i >>$BASE_PERMISSION
      done

    else

      for i in $(find $dir | grep -v -f exclude_file); do
        echo $i" \c" >>$BASE_PERMISSION
        istat $i | tr '\n' ' ' | awk '{print $8, $10, $12}' >>$BASE_PERMISSION
      done

    fi

  done
}

create_base_md5() {
  # create hash baseline.
  #
  # example:

  echo "Please wait..."
  rm $BASE_MD5 >/dev/null 2>&1
  for dir in $DIRECTORY_YOU_WANT_TO_CHECK_MD5; do
    echo "Parsing $dir hash now..."
    echo ""
    if [[ $OS = "Linux" ]]; then

      for i in $(find $dir -type f | grep -v -f exclude_file); do
        md5sum $i >>$BASE_MD5
      done

    else

      for i in $(find $dir -type f | grep -v -f exclude_file); do
        csum -h MD5 $i >>$BASE_MD5
      done

    fi

  done
}

list_dirs_permissions_by_user() {
  # example
  # 
  # spos2    read       exec /home

  if [[ "$OS" = "Linux" ]]; then
    ids=$(grep "^AllowUsers" /etc/ssh/sshd_config | sed 's/AllowUsers//g' |sed 's/itmadm@10.0.31.235//g')
  else
    ids=$(lsuser ALL | grep rlogin=true | awk '{print $1}')
  fi

  if [[ -z "${ids}" ]]; then
    ids=$(cat /etc/passwd | awk -F':' '/.*sh$/  {print $1}')
  fi

  echo "Please wait..."
  >$ACCESS_REPORT

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

main() {
  # The entry for sub functions.
  while true; do
    cd ${_HOME}
    show_main_menu
    read choice
    clear
    case $choice in
    1) check_permission ;;
    2) check_md5 ;;
    3) create_base_permission ;;
    4) create_base_md5 ;;
    5) list_dirs_permissions_by_user ;;
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
