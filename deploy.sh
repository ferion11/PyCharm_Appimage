#!/bin/bash
P_URL="https://download-cdn.jetbrains.com/python/pycharm-community-2021.1.2.tar.gz"

P_NAME="$(echo "PyCharm")"
P_FILENAME="$(echo $P_URL | cut -d/ -f5)"
P_VERSION="$(echo $P_FILENAME | cut -d- -f3 | sed 's/\.[^.]*$//' | sed 's/\.[^.]*$//')"
WORKDIR="workdir"

#=========================
die() { echo >&2 "$*"; exit 1; };
#=========================

#add-apt-repository ppa:mystic-mirage/pycharm -y

#-----------------------------
#dpkg --add-architecture i386
sudo apt update
#apt install -y aptitude wget file bzip2 gcc-multilib
sudo apt install -y aptitude wget file bzip2
#===========================================================================================
# Get inex
# using the package
mkdir "$WORKDIR"

wget -nv $P_URL
tar xf $P_FILENAME -C "$WORKDIR/"

cd "$WORKDIR" || die "ERROR: Directory don't exist: $WORKDIR"

pkgcachedir='/tmp/.pkgdeploycache'
mkdir -p $pkgcachedir

#sudo aptitude -y -d -o dir::cache::archives="$pkgcachedir" install pycharm-community
# sudo chmod 777 $pkgcachedir -R

#extras
#wget -nv -c http://ftp.osuosl.org/pub/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-4_amd64.deb -P $pkgcachedir

#find $pkgcachedir -name '*deb' ! -name 'mesa*' -exec dpkg -x {} . \;
#echo "All files in $pkgcachedir: $(ls $pkgcachedir)"
#---------------------------------

##clean some packages to use natives ones:
#rm -rf $pkgcachedir ; rm -rf share/man ; rm -rf usr/share/doc ; rm -rf usr/share/lintian ; rm -rf var ; rm -rf sbin ; rm -rf usr/share/man
#rm -rf usr/share/mime ; rm -rf usr/share/pkgconfig; rm -rf lib; rm -rf etc;
#---------------------------------
#===========================================================================================

##fix something here:

#===========================================================================================
# appimage
cd ..

wget -nv -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" -O  appimagetool.AppImage
chmod +x appimagetool.AppImage

cat > "AppRun" << EOF
#!/bin/bash
HERE="\$(dirname "\$(readlink -f "\${0}")")"
#------------------------------

MAIN="\$HERE/pycharm-community-${P_VERSION}/bin/pycharm.sh"

export PATH="\$HERE/pycharm-community-${P_VERSION}/bin":\$PATH
"\$MAIN" "\$@" | cat

EOF
chmod +x AppRun

cp AppRun $WORKDIR
cp resource/* $WORKDIR

./appimagetool.AppImage --appimage-extract

export ARCH=x86_64; squashfs-root/AppRun -v $WORKDIR -u 'gh-releases-zsync|ferion11|$P_NAME_Appimage|continuous|$P_NAME-v${P_VERSION}-*arch*.AppImage.zsync' $P_NAME-v${P_VERSION}-${ARCH}.AppImage

rm -rf appimagetool.AppImage

echo "All files at the end of script: $(ls)"
