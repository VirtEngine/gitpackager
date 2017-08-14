#!/bin/bash

dist=`grep PRETTY_NAME /etc/*-release | awk -F '="' '{print $2}'`
OS=$(echo $dist | awk '{print $1;}')
OS1=`cut -d' ' -f1 /etc/redhat-release` >> /var/lib/megam/test.log

sudo cat >> //root/.ssh/authorized_keys <<EOF
$SSH_PUBLIC_KEY
EOF

case "$OS" in
  "Fedora")
     ip route add default via 192.168.0.1
esac

shopt -s extglob
set -o errtrace
set -o errexit

## -- default variables
DEFAULT_URL_PREFIX="https://s3.amazonaws.com/vertice"

gup_dir="/usr/share/megam/verticegulpd"

gup_archive_dir="$gup_dir/backup"

gup_tmp_dir="$gup_dir/tmp"

gup_bin="${gup_dir}/bin/gulpd"

gup_conf="${gup_dir}/conf/gulpd.conf"

gup_version="${gup_dir}/VERSION"

gup_archive_bin="${gup_archive_dir}/bin/gulpd"

gup_archive_conf="${gup_archive_dir}/conf/gulpd.conf"

gup_archive_version="${gup_archive_dir}/VERSION"

initialize() {
  BASH_MIN_VERSION="3.2.25"
  if
    [[ -n "${BASH_VERSION:-}" &&
      "$(\printf "%b" "${BASH_VERSION:-}\n${BASH_MIN_VERSION}\n" | LC_ALL=C \sort -t"." -k1,1n -k2,2n -k3,3n | \head -n1)" != "${BASH_MIN_VERSION}"
    ]]
  then
    echo "BASH ${BASH_MIN_VERSION} required (you have $BASH_VERSION)"
    exit 1
  fi

  export HOME PS4
  export gup_trace_flag gup_debug_flag

  PS4="+ \${BASH_SOURCE##\} : \${FUNCNAME[0]:+\${FUNCNAME[0]}()}  \${LINENO} > "
}

log()  { printf "%b\n" "$*"; }
debug(){ [[ ${gup_debug_flag:-0} -eq 0 ]] || printf "%b\n" "Running($#): $*"; }
fail() { log "\nERROR: $*\n" ; exit 1 ; }

install_commands_setup() {
  \which which >/dev/null 2>&1 || fail "Could not find 'which' command, make sure it's available first before continuing installation."
  \which grep >/dev/null 2>&1 || fail "Could not find 'grep' command, make sure it's available first before continuing installation."
  if
    [[ -z "${gup_tar_command:-}" ]] && builtin command -v tar >/dev/null
  then
    gup_tar_command=tar
  elif
    ${gup_tar_command:-tar} --help 2>&1 | GREP_OPTIONS="" \grep -- --strip-components >/dev/null
  then
    gup_tar_command="${gup_tar_command:-tar}"
  else
    case "$(uname)" in
      (OpenBSD)
        log "Trying to install GNU version of tar, might require sudo password"
        if (( UID ))
        then sudo pkg_add -z gtar-1
        else pkg_add -z gtar-1
        fi
        gup_tar_command=gtar
        ;;
      (Darwin|FreeBSD|DragonFly) # it's not possible to autodetect on OSX, the help/man does not mention all flags
        gup_tar_command=tar
        ;;
    esac
    builtin command -v ${gup_tar_command:-gtar} >/dev/null ||
    fail "Could not find GNU compatible version of 'tar' command, make sure it's available first before continuing installation."
  fi
  if
    [[ " ${gup_tar_options:-} " != *" --no-same-owner "*  ]] &&
    $gup_tar_command --help 2>&1 | GREP_OPTIONS="" \grep -- --no-same-owner >/dev/null
  then
    gup_tar_options="${gup_tar_options:-}${gup_tar_options:+ }--no-same-owner"
  fi
}


usage() {
  echo "Usage: gulpupd [OPTION]"
  echo
  echo "Options:"
  echo
  echo "  --version <version>"
  echo "  --branch <branch>"
  echo "  --help"
  echo
  echo "For more information, see:"
  echo "  http://docs.megam.io"

}

parse_params() {
  flags=()

  while
    (( $# > 0 ))
  do
    token="$1"
    shift
    case "$token" in

      (--trace)
        set -o xtrace
        gup_trace_flag=1
        flags=( -x "${flags[@]}" "$token" )
        ;;

      (--debug)
        flags+=( "$token" )
        token=${token#--}
        token=${token//-/_}
        export "gup_${token}_flag"=1
        printf "%b" "Turning on ${token/_/ } mode.\n"
        ;;

      (--branch|branch) # Install GULPD from a given testing/stable branch
        if [[ -n "${1:-}" ]]
        then
          case "$1" in
            (/*)
              branch=${1#/}
              ;;
            (*/)
              branch=${1%/*}
              ;;
            (*/*)
              branch=${1#*/}
              ;;
            (*)
              branch="$1"
              ;;
          esac
          shift
        else
          fail "--branch must be followed by a branchname."
        fi
        ;;

     (--version|version)
        version="$1"
        shift
        ;;

     (help|usage)
        usage
        exit 0
        ;;

      (*)
        usage
        exit 1
        ;;

    esac
  done

  true "${version:=1.5.1}"
  true "${branch:=testing}"

  source_url=$DEFAULT_URL_PREFIX/$branch/$version/gulpd.tar.gz
  source_version=$DEFAULT_URL_PREFIX/$branch/$version/VERSION

  log "⊙▂⊙ Upgrade ${version} -> ${branch}"  
}

get_and_compare_version() {
  compare_version $(fetch_source_version $source_version) $(fetch_version) || exit $?
}

compare_version() {
  typeset _source_version _current_version
  _source_version=$1
  _current_version=$2

  if
    [[ -n ${_source_version} &&  -n ${_current_version} ]]
  then
    if
      [[ ${_source_version} != ${_current_version} ]]
    then
      log "●▪● Upgrading ${version} -> ${_source_version}"  
      return 0
	  fi
  fi

  log "●▪● Up-to-date. All is well."  

  return 0
}


install_release() {
  typeset _url _verify_md5
  _url=$source_url
  _verify_md5="${_url}.md5"

  log "Installing ${_url}" 

  # rm -r "$gup_tmp_dir" Does curl automatically refresh it ?
  mkdir -p "$gup_tmp_dir"

  get_and_unpack "${_url}" "gulpd.tar.gz" "$_verify_md5" && return

  log "●▪● Upgrade. failed."  
  return $?
}

get_and_unpack() {
  typeset _url _file _patern _return _verify_pgp
  _url="$1"
  _file="$2"
  _verify_md5="$3"

  get_package "$_url" "$_file" || return $?
  verify_md5 "$_verify_md5" "$_file" || return $?

  [[ -d "${gup_dir}" ]] || \mkdir -p "${gup_dir}"
  __gup_cd "${gup_dir}" ||
  {
    _return=$?
    log "Could not change directory '${gup_dir}'."  
    return $_return
  }

  archive_current

  __gup_cd "${gup_dir}" ||
  {
    _return=$?
    log "Could not change directory '${gup_dir}'." 
    return $_return
  }
  __gup_debug_command  $gup_tar_command -xzf ${gup_tmp_dir}/${_file} ${gup_tar_options:-}  ||
  {
    rollback_old
    _return=$?
    log "Could not extract Gulpd sources." 
    return $_return
  }
  log "●▪● Upgraded. All is well." 

}

get_package() {
  typeset _url _file
  _url="$1"
  _file="$2"

  log "Downloading ${_url}"  
  __gup_curl -sS ${_url} -o ${gup_tmp_dir}/${_file} ||
  {
    _return=$?
    case $_return in
      (60)
        log "
Could not download '${_url}', you can read more about it here:
To continue in insecure mode run 'echo insecure >> ~/.curlrc'.
" 
        ;;
      # duplication marker lfdgzkngdkjvnfjknkjvcnbjkncvjxbn
      (77)
        log "
It looks like you have old certificates.
"
        ;;
      # duplication marker lfdgzkngdkjvnfjknkjvcnbjkncvjxbn
      (141)
        log "
Curl returned 141 - it is result of a segfault which means it's Curls fault.
Try again and if it crashes more than a couple of times you either need to
reinstall Curl or consult with your distribution manual and contact support.
" 
        ;;
      (*)
        log "
Could not download '${_url}'.
  curl returned status '$_return'.
" 
        ;;
    esac
    return $_return
  }
}

verify_md5() {
  [[ -n "${1:-}" ]] ||
  {
    log "No MD5 url given, skipping."  
    return 0
  }

  get_package "$1" "$2.md5" ||
  {
    log "MD5 url given but does not exist: '$1'"  
    return 0
  }

  gup_install_md5_setup ||
  {
    log "Found MD5 hash at: '$1',
but no MD5 software exists to validate it, skipping."
    return 0
  }

  verify_package_md5 "${gup_tmp_dir}/$2" "${gup_tmp_dir}/$2.md5" "$1"
}

# duplication marker flnglfdjkngjndkfjhsbdjgfghdsgfklgg
gup_install_md5_setup() {
  export gup_md5_command
  {
    gup_md5_command="$( \which md5sum 2>/dev/null )" &&
    [[ ${gup_md5_command} != "/cygdrive/"* ]]
  } ||
    gup_md5_command="$( \which md5 2>/dev/null )" ||
    gup_md5_command=""
    log "Detected MD5 program: '$gup_md5_command'" 
  [[ -n "$gup_md5_command" ]] || return $?
}

# duplication marker rdjgndfnghdfnhgfdhbghdbfhgbfdhbn
verify_package_md5() {
  __gup_cd "${gup_tmp_dir}" ||
  {
    _return=$?
    log "Could not change directory '${gup_tmp_dir}'." 
    return $_return
  }

  if
    "${gup_md5_command}" -c "$2"
  then
    log "MD5 verified '$1'" 
  else
    typeset _ret=$?
    log "\
MD5 hash verification failed for '$1' - '$3'!
try running the script again.
" 
    exit $_ret
  fi
}

archive_current() {
  mkdir -p "$gup_archive_dir"

  for garc in "$gup_archive_bin" "$gup_archive_conf" "$gup_archive_version"
  do
    if
    [[ -f "$garc" ]]
      then
        rm "$garc"
    fi
  done

  for gup in "$gup_bin" "$gup_conf" "$gup_version"
  do
    if
    [[ -f "$gup" ]]
      then
        mv "$gup" "$gup_archive_dir"
    fi
  done
  log "Archived." 
}

rollback_old() {
log "Rolling..." 
}

# Searches the VERSION for the highest available version matching a branch
fetch_source_version() {
  typeset  _url
  _url=$1

  _version="$(
      _fetch_source_version ${_url} | tail -n 1
    )"

    if
      [[ -n ${_version} ]]
    then
      echo "${_version}"
      return 0
    fi

}

# Returns a sorted list of all version tags from a repository
_fetch_source_version() {
  typeset _url _version
  _url=$1

  __gup_curl -s $_url |
    \awk -v RS='\n' -v FS='=' '$1=="git_version"{print $2}'

}

# Searches the VERSION for the highest available version matching a branch
# fetch_version ( s3.aws.com/vertice/1.5/testing/VERSION. -> latest in 1.5 branch
fetch_version() {
  typeset  _version

  _version="$(
       cat $gup_version | awk -v RS='\n' -v FS='=' '$1=="git_version"{print $2}'
     )"

  if
    [[ -n ${_version} ]]
  then
    echo "${_version}"
    return 0
  fi
}

__gup_curl_output_control() {
  if
    (( ${gup_quiet_curl_flag:-0} == 1 ))
  then
    __flags+=( "--silent" "--show-error" )
  elif
    [[ " $*" == *" -s"* || " $*" == *" --silent"* ]]
  then
    # make sure --show-error is used with --silent

    [[ " $*" == *" -S"* || " $*" == *" -sS"* || " $*" == *" --show-error"* ]] ||
    {
      __flags+=( "--show-error" "-v" )
    }
  fi
}

# -S is automatically added to -s
__gup_curl()
(
  __gup_which curl >/dev/null ||  {
    gup_error "gulpupd requires 'curl'. Install 'curl' first and try again."
    return 200
  }

  typeset -a __flags
  __flags=( --fail --location --max-redirs 10 )

  [[ "$*" == *"--max-time"* ]] ||
  [[ "$*" == *"--connect-timeout"* ]] ||
    __flags+=( --connect-timeout 30 --retry-delay 2 --retry 3 )

  __gup_curl_output_control

  unset curl
  __gup_debug_command \curl "${__flags[@]}" "$@" || return $?
)

# duplication marker dfkjdjngdfjngjcszncv
# Drop in cd which _doesn't_ respect cdpath
__gup_cd()
{
  typeset old_cdpath ret
  ret=0
  old_cdpath="${CDPATH}"
  CDPATH="."
  chpwd_functions="" builtin cd "$@" || ret=$?
  CDPATH="${old_cdpath}"
  return $ret
}

gup_error()  { printf "ERROR: %b\n" "$*"; }
__gup_which(){   which "$@" || return $?; true; }
__gup_debug_command() {
  debug "Running($#): $*"
  "$@" || return $?
  true
}

# --- subfunctions (end) ---

vertsbegin() {
  initialize
  install_commands_setup
  parse_params "$@"
  get_and_compare_version
  install_release
}

vertsbegin "$@" 

if [ "$OS" = "Red Hat" ]  || [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian" ] || [ "$OS" = "CentOS" ] || [ "$OS1" = "CentOS" ] || [ "$OS" = "Fedora" ]
then
echo $OS  >> /var/lib/megam/test.log
CONF='//var/lib/megam/gulp/gulpd.conf'
else
  CONF='//var/lib/megam/verticegulpd/conf/gulpd.conf'
fi
cat >$CONF  <<'EOF'
### Welcome to the Gulpd configuration file.

  ###
  ### [meta]
  ###
  ### Controls the parameters for the Raft consensus group that stores metadata
  ### about the gulp.
  ###

  [meta]
    user = "root"
    vertice_api = "http://localhost:9000/v2" #Change to VirtEngine API Location
    nsqd = ["localhost:4150"] #Change to VirtEngine NSQD Location
		   
    name_gulp = "solutions.det.io"
    api_key = "abcdefghijklmnopqrstuvwxyz.,"
    account_id = "temporary@det.io"
    assembly_id = "ASM6054404599503290163"
    assemblies_id = "AMS4797637690447572801"

  ###
  ### [gulpd]
  ###
  ### Controls which assembly to be deployed into machine
  ###

  [gulpd]
    enabled = true
    provider = "gru"
		
    gru = "https://github.com/virtengine/gru.git"
    gru_tarball = "https://github.com/virtengine/gru/archive/0.1.tar.gz"

  ###
  ### [http]
  ###
  ### Controls how the HTTP endpoints are configured. This a frill
  ### mechanism for pinging gulpd (ping)
  ###

  [http]
    enabled = false
    bind_address = "127.0.0.1:6666"

EOF

				
sed -i "s/^[ \t]*name_gulp.*/    name = \"$NODE_NAME\"/" $CONF
sed -i "s/^[ \t]*api_key.*/    api_key = \"$API_KEY\"/" $CONF
sed -i "s/^[ \t]*assemblies_id.*/    assemblies_id = \"$ASSEMBLIES_ID\"/" $CONF
sed -i "s/^[ \t]*assembly_id.*/    assembly_id = \"$ASSEMBLY_ID\"/" $CONF
sed -i "s/^[ \t]*account_id.*/    account_id = \"$ACCOUNTS_ID\"/" $CONF

case "$OS1" in
   "CentOS")
        yum install -y glib*
	echo "----------------------" >> /var/lib/megam/test.log
        sudo service verticegulpd start  >>/var/lib/megam/test.log
        sudo service cgconfig start >>/var/lib/megam/test.log
        sudo service cadvisor start  >>/var/lib/megam/test.log
	echo "----------------------" >> /var/lib/megam/test.log
          ;;
esac


case "$OS" in
   "Ubuntu")
dist=`grep VERSION_ID /etc/*-release | awk -F '="' '{print $2}'`
v=$(echo $dist | awk -F '"' '{print $1;}')

  case "$v" in
         "14.04")
         stop verticegulpd  >/dev/null 2>&1 || echo "already stopped" >>/var/lib/megam/test 
         echo "trying to start verticegulpd" >>/var/lib/megam/test 
         start verticegulpd
          ;;
         "16.04")
          service verticegulpd stop
          service verticegulpd start
          service cadvisor stop
          service cadvisor start
         ;;
  esac
HOSTNAME=`hostname`
echo $HOSTNAME

sudo cat >> //etc/hosts <<EOF
127.0.0.1  `hostname` localhost
EOF

   ;;
   "Debian")
systemctl stop verticegulpd.service
systemctl start verticegulpd.service
systemctl stop cadvisor.service
systemctl start cadvisor.service
   ;;
   "Fedora")
		 
sudo systemctl stop verticegulpd.service >> /var/lib/megam/test
sudo systemctl start verticegulpd.service >> /var/lib/megam/test
sudo systemctl stop cadvisor.service  >> /var/lib/megam/test
sudo systemctl start cadvisor.service  >> /var/lib/megam/test
  ;;
   "CentOS")
systemctl stop verticegulpd.service
systemctl start verticegulpd.service
systemctl stop cadvisor.service
systemctl start cadvisor.service

   ;;
   "CoreOS")
if [ -f /mnt/context.sh ]; then
  . /mnt/context.sh
fi

sudo cat >> //home/core/.ssh/authorized_keys <<EOF
$SSH_PUBLIC_KEY
EOF

sudo -s

sudo cat > //etc/hostname <<EOF
$HOSTNAME
EOF

sudo cat > //etc/hosts <<EOF
127.0.0.1 $HOSTNAME localhost

EOF
sudo cat > //etc/systemd/network/static.network <<EOF
[Match]
Name=ens3

[Network]
Address=$ETH0_IP/27
Gateway=$ETH0_GATEWAY
DNS=8.8.8.8
DNS=8.8.4.4

   
	   
	  

EOF

sudo systemctl restart systemd-networkd

systemctl stop verticegulpd.service
systemctl start verticegulpd.service
systemctl stop cadvisor.service
systemctl start cadvisor.service
ip route add default via 192.168.0.1
;;
esac
