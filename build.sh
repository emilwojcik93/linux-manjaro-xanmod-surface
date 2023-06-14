#!/bin/bash

# [debbug mode] enable a mode of the shell where all executed commands are printed to the terminal
#set -x

OPTION1=${1}

#Color for print
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

scriptdir="$( dirname -- "$0"; )" # root dir of script
cd ${scriptdir}

function buildFn() {
    local MAKEFLAGS="-j$(nproc)" # multi-processor systems can specify the number of jobs to run simultaneously
    local _compress_modules=y # Compress modules with ZSTD (to save disk space)
    local use_tracers=n # For performance you can disable FUNCTION_TRACER/GRAPH_TRACER. Limits debugging and analyzing of the kernel.
    local use_numa=n # Disable NUMA since most users do not have multiple processors. Breaks CUDA/NvEnc.
    chmod +x ./choose-gcc-optimization.sh
    updpkgsums # update checksums of files used in PKGBUILD
    makepkg --printsrcinfo > .SRCINFO # generate .SRCINFO
    makepkg -sc --log --skippgpcheck # build package WITHOUT install WITH skip PGP sign check linux-6.3.tar ... FAILED (unknown public key 38DBBDC86092693E)
}

function releaseFn() {
    if [[ `git status --porcelain .SRCINFO` ]]; then 
      local `grep "pkgver" .SRCINFO | sed 's/ //g'`
      local `grep "pkgrel" .SRCINFO | sed 's/ //g'`
      git add .
      git commit -m "v${pkgver}-${pkgrel}"
      gh release create "v${pkgver}-${pkgrel}" --notes "Builded and released with \"build.sh\"" "./linux-manjaro-xanmod-surface-*.{pkg.tar.zst,log}"
    else
      echo -e "Nothing to release"
      exit 0
    fi
}

function installFn() {
    sudo pamac install --no-confirm ./linux-manjaro-xanmod-surface-*-x86_64.pkg.tar.zst
}

function helpFn() {
  # help how use script
  echo -e "Script to boost AUR building time (script supports short names for parameters)\n\nUsing script:\n\n${GREEN}`basename "${0}"`${NC} [--config|--package|--install|--all|--help]\n\n${GREEN}config${NC} - rewrite config file \"/etc/makepkg.conf\" (this is default [none] parameter)\n\n${GREEN}package${NC} - rewrite package file \"/usr/bin/makepkg\" ${RED}(it can be HARMFUL)${NC}\n\n${GREEN}install${NC} - install most common dependencies required for building process of many AUR packages\n\n${GREEN}all${NC} - rewrite both, config and package files and install deps ${RED}(it can be HARMFUL)${NC}\n\n${GREEN}help${NC} - get this message\n"
  exit 0
}

namingFn() {
  # start or stop services
  # echo "namingFn: ${OPTION1}"
  case "${OPTION1}" in
      --help|-h )                                                            helpFn ;;
      --config|-c )                                                 rewriteConfigFn ;;
      --package|-p )                                               rewritePackageFn ;;
      --install|-i )                                                      installFn ;;
      --all|-a )                                                              allFn ;;
      --status|-s )                                                        statusFn ;;
      "" )                                                          rewriteConfigFn ;;
      * ) echo -e "${RED}Parameter \"${OPTION1}\" is not supported.${NC}" && helpFn ;;
  esac
}

mainFn() {
  namingFn ${OPTION1}
}

#just run
mainFn ${1}