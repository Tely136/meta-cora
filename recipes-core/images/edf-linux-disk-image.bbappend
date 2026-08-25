IMAGE_INSTALL:append = " libgpiod"
IMAGE_INSTALL:append = " libgpiod-dev"
IMAGE_INSTALL:append = " cora-network"
IMAGE_INSTALL:append = " ssh-key"
IMAGE_INSTALL:append = " gpio-permissions"



inherit extrausers

PASSWD = "\$5\$DEXyV3/p230XJr1A\$chWJW2FmJUfjHcG/b5.ouTk380K5Z1U964nzV/FCRE3"

EXTRA_USERS_PARAMS:append = " \
    groupadd -f gpio; \
    usermod -a -G gpio amd-edf; \
    usermod -p '${PASSWD}' amd-edf; \
"

fix_amd_edf_ssh_permissions() {
    if [ -d ${IMAGE_ROOTFS}/home/amd-edf/.ssh ]; then
        chown -R 1000:1001 ${IMAGE_ROOTFS}/home/amd-edf/.ssh
        chmod 0700 ${IMAGE_ROOTFS}/home/amd-edf/.ssh

        if [ -f ${IMAGE_ROOTFS}/home/amd-edf/.ssh/authorized_keys ]; then
            chmod 0600 ${IMAGE_ROOTFS}/home/amd-edf/.ssh/authorized_keys
        fi
    fi
}

ROOTFS_POSTPROCESS_COMMAND += "fix_amd_edf_ssh_permissions; "