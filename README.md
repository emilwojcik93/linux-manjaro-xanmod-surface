# Linux Manjaro Xanmod Surface
This project based on original version of "[linux-manjaro-xanmod]" AUR package.
The Linux kernel and modules with Xanmod, Manjaro (Bootsplash support) and Surface patches. Ashmem and binder are enabled.

## Tips and tricks
To improve compile time it's recommends to use tips and tricks for makepkg.

- [Here are selection of choosen improvements.][aur-boost]

- [Here are full description of possible improvements.][archwiki makepkg]


## Execute using `git`

Clone whole repo to current directory and build package
```bash
url="https://github.com/emilwojcik93/linux-manjaro-xanmod-surface.git"
name=$(echo ${url} | awk -F / '{print $5}' | awk -F . '{print $1}')
git clone ${url}
cd ${name}
makepkg -sri
unset name url
```

Relevant links:
- [linux-manjaro-xanmod]
- [archwiki makepkg]
- [aur-boost]

[linux-manjaro-xanmod]: https://aur.archlinux.org/packages/linux-manjaro-xanmod
[archwiki makepkg]: https://wiki.archlinux.org/title/makepkg#Tips_and_tricks
[aur-boost]: https://github.com/emilwojcik93/aur-boost.git
