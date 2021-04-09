EFI_DISK=$(findfs 'UUID=6E69-6365')
ROOT_DEVICE=$(findfs 'UUID=4e696365-4f53-4e69-6365-4f534e696365')

efibootmgr --create --label "NiceOS" \
    --disk ${EFI_DISK::-1}  \
    --part 1 \
    --loader /vmlinuz \
    --unicode 'initrd=\initrd' \
    --verbose

echo "If efibootmgr failes to create persistent working boot entries, boot into efi shell and try 'bcfg'"
echo "If motherboard has no efi shell, use archiso or https://github.com/tianocore/edk2/releases/download/edk2-stable202002/ShellBinPkg.zip or other"
echo "Eg. for fs1 disk with priority Ox01:"
echo 'bcfg boot add 01 fs1:\vmlinuz "NiceOS"'
echo 'bcfg boot -opt 01 "initrd=\initrd"'
