## -- default variables
PACKAGE_ROUTE_DIR=""
REPO_ROUTE_DIR=""
BUILD_dir=""
repo_dir="/var/www/html/repo"
arkave="/var/www/html/arkave"

parse_params() {

  while
    (( $# > 0 ))
  do
    token="$1"
    shift
    case "$token" in
     (--root)
        root="$1"
        if [ -z "$root" ]
         then
          usage
          exit
        fi
        shift
        ;;
    (--version)
        version="$1"
        if [ -z "$version" ]
        then
          usage
          exit
        fi
        shift
        ;;
    (--distro)
        distro="$1"
        if [ -z "$distro" ]
        then
        usage
        exit
        fi
        shift
        ;;
    (--distroversion)
        distroversion="$1"
        if [ -z "$distroversion" ]
        then
          usage
          exit
        fi
        shift
        ;;
    (--distroname)
      distroname="$1"
       if [ -z "$distroname" ]
       then
         usage
         exit
       fi
       shift
        ;;
    (--release)
        release="$1"
        if [ -z "$release" ]
        then
         usage
         exit
        fi
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
}

usage() {

echo "Usage:  distrepo[OPTION]"
  echo
  echo "Options:"
  echo " --root  <root directory> "
  echo "--version <build version>"
  echo "--distro  <distribution name>"
  echo "--distroversion  <distribution version>"
  echo "--distroname  <distribution name>"
  echo "--release  <release name>"
  echo "--help"
  echo
}


initialize () {
build="$version/$distro/$distroversion"
distro_dir="$version/$distro/$distroversion/$release"

PACKAGE_ROUTE_DIR="$root/repo/$distro_dir"

REPO_ROUTE_DIR="$repo_dir/$distro_dir"

BUILD_dir="$repo_dir/$build"
}

conf() {

mkdir -p  $PACKAGE_ROUTE_DIR/conf
cd $PACKAGE_ROUTE_DIR/conf

cat > distributions <<EOF
Origin: $distro
Label: $distro
Suite: $release
Codename: $distroname
Version: $version
Architectures: amd64
Components: $release
Description: vertice
SignWith: 9B46B611
EOF

}

packagerepo() {

mkdir -p $REPO_ROUTE_DIR
cd

find $PACKAGE_ROUTE_DIR/$release-$distro -name \*.deb -exec reprepro --ask-passphrase -Vb $PACKAGE_ROUTE_DIR includedeb $distroname {} \;
mv $(find $REPO_ROUTE_DIR/pool/$release -name *.deb) $arkave
rm -r $REPO_ROUTE_DIR

mkdir  -p $REPO_ROUTE_DIR

cp -R $PACKAGE_ROUTE_DIR/conf $REPO_ROUTE_DIR && rm -R $PACKAGE_ROUTE_DIR/conf
cp -R  $PACKAGE_ROUTE_DIR/db $REPO_ROUTE_DIR && rm -R $PACKAGE_ROUTE_DIR/db
cp -R $PACKAGE_ROUTE_DIR/dists $REPO_ROUTE_DIR && rm -R $PACKAGE_ROUTE_DIR/dists
cp -R  $PACKAGE_ROUTE_DIR/pool $REPO_ROUTE_DIR && rm -R $PACKAGE_ROUTE_DIR/pool
chmod -R ugo+rX $BUILD_dir
}

start() {
parse_params "$@"
initialize
conf
packagerepo
}

start "$@"
