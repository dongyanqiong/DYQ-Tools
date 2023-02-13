

```bash
sshd             76658  1402     0 /usr/sbin/sshd -D -R
bash             76660  76658    0 /bin/bash
id               76662  76661    0 /usr/bin/id -un
hostname         76664  76663    0 /usr/bin/hostname
tty              76665  76660    0 /usr/bin/tty -s
mkdir            76666  76660    0 /usr/bin/mkdir -p /root/.cache/abrt
mktemp           76668  76667    0 /usr/bin/mktemp --tmpdir=/root/.cache/abrt lastnotification.XXXXXXXX
cat              76670  76669    0 /usr/bin/cat /root/.cache/abrt/lastnotification
date             76671  76660    0 /usr/bin/date +%s
mv               76672  76660    0 /usr/bin/mv -f /root/.cache/abrt/lastnotification.X6gw9rPX /root/.cache/abrt/lastnotification
timeout          76673  76660    0 /usr/bin/timeout 10s abrt-cli status --since=1675337537
abrt-cli         76674  76673    0 /usr/bin/abrt-cli status --since=1675337537
dbus-daemon-lau  76678  76677    0 //usr/libexec/dbus-1/dbus-daemon-launch-helper org.freedesktop.problems
abrt-dbus        76678  76677    0 /usr/sbin/abrt-dbus -t133
ls               76683  76682    0 /usr/bin/ls /etc/bash_completion.d
uname            76685  76684    0 /usr/bin/uname -o
pidof            76686  76660    0 /usr/sbin/pidof glusterd
pkg-config       76688  76687    0 /usr/bin/pkg-config --variable=completionsdir bash-completion
grepconf.sh      76689  76660    0 /usr/libexec/grepconf.sh -c
grep             76690  76689    0 /usr/bin/grep -qsi ^COLOR.*none /etc/GREP_COLORS
tty              76692  76691    0 /usr/bin/tty -s
tput             76693  76691    0 /usr/bin/tput colors
dircolors        76695  76694    0 /usr/bin/dircolors --sh /etc/DIR_COLORS.256color
grep             76696  76660    0 /usr/bin/grep -qi ^COLOR.*none /etc/DIR_COLORS.256color
id               76698  76697    0 /usr/bin/id -u
```

/var/log/secure
```shell
Feb  3 10:28:02 test1 sshd[76658]: Accepted publickey for root from 172.16.216.1 port 53979 ssh2: RSA SHA256:r932ZSSaT8FWoEjjCLEaceUDBfkook8RdAY5Zh01ln0
Feb  3 10:28:02 test1 sshd[76658]: pam_unix(sshd:session): session opened for user root by (uid=0)
Feb  3 10:28:26 test1 sshd[76658]: Received disconnect from 172.16.216.1 port 53979:11: disconnected by user
Feb  3 10:28:26 test1 sshd[76658]: Disconnected from 172.16.216.1 port 53979
Feb  3 10:28:26 test1 sshd[76658]: pam_unix(sshd:session): session closed for user root
```