FROM scratch

MAINTAINER Vikraman

# Use busybox binary as tar
ADD bb /tar

# Download stage3 tarball
ADD http://ftp.ussg.iu.edu/linux/gentoo/releases/amd64/autobuilds/20160126/stage3-amd64-20160126.tar.bz2 /

# Exclude file for tar
ADD exclude /

# Extract stage3 tarball
RUN ["/tar", "xvjpf", "stage3-amd64-20160126.tar.bz2", "-X", "exclude"]

# Cleanup
RUN rm -f tar exclude stage3-amd64-20160126.tar.bz2


# Setup the rc_sys
RUN sed -e 's/#rc_sys=""/rc_sys="lxc"/g' -i /etc/rc.conf

# By default, UTC system
RUN echo 'UTC' > /etc/timezone

# Setup the portage directory and permissions
RUN mkdir -p /usr/portage/{distfiles,metadata,packages}
RUN chown -R portage:portage /usr/portage
RUN echo "masters = gentoo" > /usr/portage/metadata/layout.conf

# Sync portage
RUN emerge-webrsync -q

# Display some news items
RUN eselect news read new

# Finalization
RUN env-update

# The glorious shell
CMD ["/bin/bash"]
