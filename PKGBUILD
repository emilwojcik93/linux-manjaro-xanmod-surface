# Maintainer: parov0z <andrey.android7890@gmail.com>

# https://gitlab.manjaro.org/packages/core/linux515
#
# Maintainer: Philip Müller
# Maintainer: Bernhard Landauer
# Maintainer: Helmut Stult

# http://aur.archlinux.org/packages/linux-xanmod
#
# Maintainer: Joan Figueras
# Contributor: Torge Matthies
# Contributor: Jan Alexander Steffens (heftig)

##
## The following variables can be customized at build time. Use env or export to change at your wish
##
##   Example: env _microarchitecture=99 use_numa=n use_tracers=n makepkg -sc
##
## Look inside 'choose-gcc-optimization.sh' to choose your microarchitecture
## Valid numbers between: 0 to 99
## Default is: 0 => generic
## Good option if your package is for one machine: 98 (Intel native) or 99 (AMD native)
if [ -z ${_microarchitecture+x} ]; then
  _microarchitecture=0
fi

## Disable NUMA since most users do not have multiple processors. Breaks CUDA/NvEnc.
## Archlinux and Xanmod enable it by default.
## Set variable "use_numa" to: n to disable (possibly increase performance)
##                             y to enable  (stock default)
if [ -z ${use_numa+x} ]; then
  use_numa=y
fi

## For performance you can disable FUNCTION_TRACER/GRAPH_TRACER. Limits debugging and analyzing of the kernel.
## Stock Archlinux and Xanmod have this enabled.
## Set variable "use_tracers" to: n to disable (possibly increase performance)
##                                y to enable  (stock default)
if [ -z ${use_tracers+x} ]; then
  use_tracers=y
fi

# Unique compiler supported upstream is GCC
## Choose between GCC and CLANG config (default is GCC)
## Use the environment variable "_compiler=clang"
if [ "${_compiler}" = "clang" ]; then
  _compiler_flags="CC=clang HOSTCC=clang LLVM=1 LLVM_IAS=1"
fi

# Choose between the 4 main configs for stable branch. Default x86-64-v1 which use CONFIG_GENERIC_CPU2:
# Possible values: config_x86-64-v1 (default) / config_x86-64-v2 / config_x86-64-v3 / config_x86-64-v4
# This will be overwritten by selecting any option in microarchitecture script
# Source files: https://github.com/xanmod/linux/tree/5.17/CONFIGS/xanmod/gcc
if [ -z ${_config+x} ]; then
  _config=config_x86-64-v1
fi

# Compress modules with ZSTD (to save disk space)
if [ -z ${_compress_modules+x} ]; then
  _compress_modules=n
fi

# Compile ONLY used modules to VASTLY reduce the number of modules built
# and the build time.
#
# To keep track of which modules are needed for your specific system/hardware,
# give module_db script a try: https://aur.archlinux.org/packages/modprobed-db
# This PKGBUILD read the database kept if it exists
#
# More at this wiki page ---> https://wiki.archlinux.org/index.php/Modprobed-db
if [ -z ${_localmodcfg} ]; then
  _localmodcfg=n
fi

# Tweak kernel options prior to a build via nconfig
if [ -z ${_makenconfig} ]; then
  _makenconfig=n
fi

### IMPORTANT: Do no edit below this line unless you know what you're doing


pkgbase=linux-manjaro-xanmod-surface
pkgname=("${pkgbase}" "${pkgbase}-headers")
_major=6.3
pkgver=${_major}.7
_branch=6.x
xanmod=1
pkgrel=1
pkgdesc='Linux Xanmod Surface'
url="http://www.xanmod.org/"
arch=(x86_64)

__commit="9316d222a6d0b0401b6bf04d57aab84c232a28cf" # 6.3.7-1

license=(GPL2)
makedepends=(
  xmlto kmod inetutils bc perl libelf cpio gettext tar xz
  python python-sphinx python-sphinx_rtd_theme graphviz imagemagick git
)
if [ "${_compiler}" = "clang" ]; then
  makedepends+=(clang llvm lld python)
fi
options=('!strip')
_srcname="linux-${pkgver}-xanmod${xanmod}"

source=("https://cdn.kernel.org/pub/linux/kernel/v${_branch}/linux-${_major}.tar."{xz,sign}
        "https://github.com/xanmod/linux/releases/download/${pkgver}-xanmod${xanmod}/patch-${pkgver}-xanmod${xanmod}.xz"
        "choose-gcc-optimization.sh"
        "https://gitlab.manjaro.org/packages/core/linux${_major//.}/-/archive/${__commit}/linux${_major//.}-${__commit}.tar.gz"
        "git+https://github.com/linux-surface/linux-surface.git")
        
sha256sums=('ba3491f5ed6bd270a370c440434e3d69085fcdd528922fa01e73d7657db73b1e'
            'SKIP'
            '9cec6c03e14daf279ed1704e408009eda9b56d15e91855cf1e97da2e4cc38c21'
            '5c84bfe7c1971354cff3f6b3f52bf33e7bbeec22f85d5e7bfde383b54c679d30'
            'cfc504a838b4a7804adcc6961435e58ed17fa821e74e6d79fda216f8679e263e'
            'SKIP')

validpgpkeys=('ABAF11C65A2970B130ABE3C479BE3E4300411886' # Linux Torvalds
              '647F28654894E3BD457199BE38DBBDC86092693E' # Greg Kroah-Hartman
              'A2FF3A36AAA56654109064AB19802F8B0D70FC30') # Jan Alexander Steffens (heftig)

export KBUILD_BUILD_HOST=${KBUILD_BUILD_HOST:-archlinux}
export KBUILD_BUILD_USER=${KBUILD_BUILD_USER:-makepkg}
export KBUILD_BUILD_TIMESTAMP=${KBUILD_BUILD_TIMESTAMP:-$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})}

# optional certificate and key for secure boot signing
_mok_crt="$PWD/MOK.crt"
_mok_key="$PWD/MOK.key"

prepare() {
  cd linux-${_major}  
  
  # Apply Xanmod patch
  patch -Np1 -i ../patch-${pkgver}-xanmod${xanmod}
  
  msg2 "Setting version..."
  #echo "-$pkgrel" > localversion.10-pkgrel
  echo "-surface-MANJARO" > localversion.20-pkgname

  # Archlinux patches
  local src
  for src in "${source[@]}"; do
    src="${src%%::*}"
    src="${src##*/}"
    [[ $src = *.patch ]] || continue
    msg2 "Applying patch $src..."
    patch -Np1 < "../$src"
  done
  
  # Manjaro patches 
  
  # remove conflicting ones
  rm ../linux${_major//.}-$__commit/0101-ZEN_Add_sysctl_and_CONFIG_to_disallow_unprivileged_CLONE_NEWUSER.patch
  
  local _patch
  for _patch in ../linux${_major//.}-$__commit/*; do
      [[ $_patch = *.patch ]] || continue
      msg2 "Applying patch: $_patch..."
      patch -Np1 < "../linux${_major//.}-$__commit/$_patch"
  done 
  git apply -p1 < "../linux${_major//.}-$__commit/0413-bootsplash.gitpatch"
  
  # surface patches 
  for p in ../linux-surface/patches/${_major}/*; do
      msg2 "Applying patch: $p"
      patch -Np1 < $p
  done
  
  # Applying configuration
  cp -vf CONFIGS/xanmod/gcc/${_config} .config
  # enable LTO_CLANG_THIN
  if [ "${_compiler}" = "clang" ]; then
    scripts/config --disable LTO_CLANG_FULL
    scripts/config --enable LTO_CLANG_THIN
  fi
  
  scripts/config --enable CONFIG_BOOTSPLASH
  
  # CONFIG_STACK_VALIDATION gives better stack traces. Also is enabled in all official kernel packages by Archlinux team
  scripts/config --enable CONFIG_STACK_VALIDATION

  # Enable IKCONFIG following Arch's philosophy
  scripts/config --enable CONFIG_IKCONFIG \
                 --enable CONFIG_IKCONFIG_PROC

  # User set. See at the top of this file
  if [ "$use_tracers" = "n" ]; then
    msg2 "Disabling FUNCTION_TRACER/GRAPH_TRACER only if we are not compiling with clang..."
    if [ "${_compiler}" = "gcc" ]; then
      scripts/config --disable CONFIG_FUNCTION_TRACER \
                     --disable CONFIG_STACK_TRACER
    fi
  fi

  if [ "$use_numa" = "n" ]; then
    msg2 "Disabling NUMA..."
    scripts/config --disable CONFIG_NUMA
  fi
    
  msg2 "add anbox support"
  scripts/config --enable CONFIG_ASHMEM
  # CONFIG_ION is not set
  scripts/config --enable CONFIG_ANDROID
  scripts/config --enable CONFIG_ANDROID_BINDER_IPC
  scripts/config --enable CONFIG_ANDROID_BINDERFS
  scripts/config --set-str CONFIG_ANDROID_BINDER_DEVICES "binder,hwbinder,vndbinder"
  scripts/config --enable CONFIG_FRAMEBUFFER_CONSOLE_LEGACY_ACCELERATION
  # CONFIG_ANDROID_BINDER_IPC_SELFTEST is not set
  
  scripts/config --set-str CONFIG_DEFAULT_HOSTNAME "manjaro"

  # Compress modules by default (following Arch's kernel)
  if [ "$_compress_modules" = "y" ]; then
    scripts/config --enable CONFIG_MODULE_COMPRESS_ZSTD
  fi

  # Let's user choose microarchitecture optimization in GCC
  # Use default microarchitecture only if we have not choosen another microarchitecture
  if [ "$_microarchitecture" -ne "0" ]; then
    ../choose-gcc-optimization.sh $_microarchitecture
  fi  

  # This is intended for the people that want to build this package with their own config
  # Put the file "myconfig" at the package folder (this will take preference) or "${XDG_CONFIG_HOME}/linux-xanmod/myconfig"
  # If we detect partial file with scripts/config commands, we execute as a script
  # If not, it's a full config, will be replaced
  for _myconfig in "${SRCDEST}/myconfig" "${HOME}/.config/linux-xanmod/myconfig" "${XDG_CONFIG_HOME}/linux-xanmod/myconfig" ; do
    if [ -f "${_myconfig}" ] && [ "$(wc -l <"${_myconfig}")" -gt "0" ]; then
      if grep -q 'scripts/config' "${_myconfig}"; then
        # myconfig is a partial file. Executing as a script
        msg2 "Applying myconfig..."
        bash -x "${_myconfig}"
      else
        # myconfig is a full config file. Replacing default .config
        msg2 "Using user CUSTOM config..."
        cp -f "${_myconfig}" .config
      fi
      echo
      break
    fi
  done

  ### Optionally load needed modules for the make localmodconfig
  # See https://aur.archlinux.org/packages/modprobed-db
  if [ "$_localmodcfg" = "y" ]; then
    if [ -f $HOME/.config/modprobed.db ]; then
      msg2 "Running Steven Rostedt's make localmodconfig now"
      make ${_compiler_flags} LSMOD=$HOME/.config/modprobed.db localmodconfig
    else
      msg2 "No modprobed.db data found"
      exit 1
    fi
  fi

  scripts/kconfig/merge_config.sh -m .config ../linux-surface/configs/surface-6.3.config

  make ${_compiler_flags} olddefconfig

  make -s kernelrelease > version
  msg2 "Prepared %s version %s" "$pkgbase" "$(<version)"

  if [ "$_makenconfig" = "y" ]; then
    make ${_compiler_flags} nconfig
  fi

  # save configuration for later reuse
  cat .config > "${SRCDEST}/config.last"
}

build() {
  cd linux-${_major}
  make ${_compiler_flags} all
}

_package() {
  pkgdesc="The Linux kernel and modules with Xanmod, Manjaro (Bootsplash support) and Surface patches. Ashmem and binder are enabled"
  depends=('coreutils' 'linux-firmware' 'kmod' 'initramfs')
  optdepends=('crda: to set the correct wireless channels of your country'
              'linux-firmware: firmware images needed for some devices'
              'bootsplash-systemd: for bootsplash functionality'
              'iptsd: Touchscreen support'
              'linux-firmware: Firmware files for Linux'
              'linux-firmware-marvell: Firmware files for Marvell WiFi / Bluetooth')
  provides=(VIRTUALBOX-GUEST-MODULES
            WIREGUARD-MODULE
            KSMBD-MODULE
            NTFS3-MODULE)
  replaces=(
    virtualbox-guest-modules-arch
    wireguard-arch
  )
  conflicts=()

  cd linux-${_major}
  local kernver="$(<version)"
  local modulesdir="$pkgdir/usr/lib/modules/$kernver"

  # sign boot image if the prequisites are available
  if [[ -f "$_mok_crt" ]] && [[ -f "$_mok_key" ]] && [[ -x "$(command -v sbsign)" ]]; then
    echo "Signing boot image..."
    sbsign --key "$_mok_key" --cert "$_mok_crt" --output "$image_name" "$image_name"
  fi

  msg2 "Installing boot image..."
  # systemd expects to find the kernel here to allow hibernation
  # https://github.com/systemd/systemd/commit/edda44605f06a41fb86b7ab8128dcf99161d2344
  install -Dm644 "$(make -s image_name)" "$modulesdir/vmlinuz"

  # Used by mkinitcpio to name the kernel
  echo "manjaro-xanmod-surface" | install -Dm644 /dev/stdin "$modulesdir/pkgbase"
 
  # add kernel version
  echo "${pkgver}-${pkgrel}-Manjaro-Xanmod-Surface x64" | install -Dm644 /dev/stdin "${pkgdir}/boot/${pkgbase}.kver"

  msg2 "Installing modules..."
  make INSTALL_MOD_PATH="$pkgdir/usr" INSTALL_MOD_STRIP=1 modules_install

  # remove build and source links
  rm "$modulesdir"/{source,build}
}

_package-headers() {
  pkgdesc="Headers and scripts for building modules for the $pkgdesc kernel"
  depends=(pahole)
  provides=()
  replaces=()
  conflicts=()

  cd linux-${_major}
  local builddir="$pkgdir/usr/lib/modules/$(<version)/build"

  msg2 "Installing build files..."
  install -Dt "$builddir" -m644 .config Makefile Module.symvers System.map \
    localversion.* version vmlinux
  install -Dt "$builddir/kernel" -m644 kernel/Makefile
  install -Dt "$builddir/arch/x86" -m644 arch/x86/Makefile
  cp -t "$builddir" -a scripts

  # required when STACK_VALIDATION is enabled
  install -Dt "$builddir/tools/objtool" tools/objtool/objtool

  # required when DEBUG_INFO_BTF_MODULES is enabled
  if [ -f "tools/bpf/resolve_btfids/resolve_btfids" ]; then install -Dt "$builddir/tools/bpf/resolve_btfids" tools/bpf/resolve_btfids/resolve_btfids ; fi

  msg2 "Installing headers..."
  cp -t "$builddir" -a include
  cp -t "$builddir/arch/x86" -a arch/x86/include
  install -Dt "$builddir/arch/x86/kernel" -m644 arch/x86/kernel/asm-offsets.s

  install -Dt "$builddir/drivers/md" -m644 drivers/md/*.h
  install -Dt "$builddir/net/mac80211" -m644 net/mac80211/*.h

  # https://bugs.archlinux.org/task/13146
  install -Dt "$builddir/drivers/media/i2c" -m644 drivers/media/i2c/msp3400-driver.h

  # https://bugs.archlinux.org/task/20402
  install -Dt "$builddir/drivers/media/usb/dvb-usb" -m644 drivers/media/usb/dvb-usb/*.h
  install -Dt "$builddir/drivers/media/dvb-frontends" -m644 drivers/media/dvb-frontends/*.h
  install -Dt "$builddir/drivers/media/tuners" -m644 drivers/media/tuners/*.h
  
  # https://bugs.archlinux.org/task/71392
  install -Dt "$builddir/drivers/iio/common/hid-sensors" -m644 drivers/iio/common/hid-sensors/*.h

  msg2 "Installing KConfig files..."
  find . -name 'Kconfig*' -exec install -Dm644 {} "$builddir/{}" \;

  msg2 "Removing unneeded architectures..."
  local arch
  for arch in "$builddir"/arch/*/; do
    [[ $arch = */x86/ ]] && continue
    echo "Removing $(basename "$arch")"
    rm -r "$arch"
  done

  msg2 "Removing documentation..."
  rm -r "$builddir/Documentation"

  msg2 "Removing broken symlinks..."
  find -L "$builddir" -type l -printf 'Removing %P\n' -delete

  msg2 "Removing loose objects..."
  find "$builddir" -type f -name '*.o' -printf 'Removing %P\n' -delete

  msg2 "Stripping build tools..."
  local file
  while read -rd '' file; do
    case "$(file -bi "$file")" in
      application/x-sharedlib\;*)      # Libraries (.so)
        strip -v $STRIP_SHARED "$file" ;;
      application/x-archive\;*)        # Libraries (.a)
        strip -v $STRIP_STATIC "$file" ;;
      application/x-executable\;*)     # Binaries
        strip -v $STRIP_BINARIES "$file" ;;
      application/x-pie-executable\;*) # Relocatable binaries
        strip -v $STRIP_SHARED "$file" ;;
    esac
  done < <(find "$builddir" -type f -perm -u+x ! -name vmlinux -print0)

  msg2 "Stripping vmlinux..."
  strip -v $STRIP_STATIC "$builddir/vmlinux"
  msg2 "Adding symlink..."
  mkdir -p "$pkgdir/usr/src"
  ln -sr "$builddir" "$pkgdir/usr/src/$pkgbase"
}

pkgname=("${pkgbase}" "${pkgbase}-headers")
for _p in "${pkgname[@]}"; do
  eval "package_$_p() {
    $(declare -f "_package${_p#$pkgbase}")
    _package${_p#$pkgbase}
  }"
done
