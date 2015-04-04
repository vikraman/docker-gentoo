FROM scratch

MAINTAINER Vikraman

# Use busybox binary as tar
ADD bb /tar

# Download stage3 tarball
ADD http://ftp.ussg.iu.edu/linux/gentoo/releases/amd64/autobuilds/20150402/stage3-amd64-20150402.tar.bz2 /

# Exclude file for tar
ADD exclude /

# Extract stage3 tarball
RUN ["/tar", "xvjpf", "stage3-amd64-20150402.tar.bz2", "-X", "exclude"]

# Cleanup
RUN rm -f tar exclude stage3-amd64-20150402.tar.bz2

# Setup the (virtually) current runlevel
RUN echo "default" > /run/openrc/softlevel

# Setup the rc_sys
RUN sed -e 's/#rc_sys=""/rc_sys="lxc"/g' -i /etc/rc.conf

# Setup the net.lo runlevel
RUN ln -s /etc/init.d/net.lo /run/openrc/started/net.lo

# Setup the net.eth0 runlevel
RUN ln -s /etc/init.d/net.lo /etc/init.d/net.eth0
RUN ln -s /etc/init.d/net.eth0 /run/openrc/started/net.eth0

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
