# Systemd Packet Capture

This is a `service` file that can be used with
[systemd](https://www.freedesktop.org/wiki/Software/systemd/)
to run a ring buffer packet capture with [tcpdump](http://www.tcpdump.org/). It
will start a packet capture and begin saving a pcap file to disk. Once that file
reaches the configured size it will begin writing packets to a new file. Then
once the maximum number of files is reached it will go back to the first file
and begin overwriting files creating a ring buffer.

## Installation

Copy the `packet-capture@.service` file to `/usr/lib/systemd/system/` and reload
systemd by running `systemctl daemon-reload`. A packet capture can then be
started on a specific interface by running `systemctl start
packet-capture@<interface>`. The pcap files will begin to be written to
`/var/tmp` in the format `pcap-<interface>-<file number>`. These will always
start at file number 0 so restarting this will immediately begin by overwriting
the first file. Systemd can also start this at boot time by running `systemctl
enable packet-capture@<interface>`.

## Configuration

Configuration is done in the service file itself with the `Environment=`
directive. The following variables can be set:

```
# Max file size
Environment="FILESIZE=25"
# Max number of files
Environment="FILELIMIT=10"
# BPF filter
Environment="FILTER="
# Additional arguments to tcpdump
Environment="ADDITIONAL_ARGS="
```

After editing the service file systemd will need to be reloaded by running
`systemctl daemon-reload`.

The `FILTER` is a [bpf filter](http://biot.com/capstats/bpf.html) that can be
used to filter the packets saved to the pcap files. Any additional arguments to
`tcpdump` can be added with the `ADDITIONAL_ARGS`. One possible addition
argument is the `-z postrotate-command`. This can be used to run
`postrotate-command file` when tcpdump begins saving to a new pcap file. This
could be used to perform post-processing on the capture such as running it
through [Suricata](https://suricata-ids.org/) or uploading the capture.

## CloudShark Ring Upload

One example script that can be used with the postrotate command is
[cloudshark_ring_upload.sh](/cloudshark_ring_upload.sh). This can be copied to
`/usr/local/bin` and reads a [config file](/cloudshark.conf) located at
`/etc/cloudshark.conf` for the URL of a [CloudShark](https://cloudshark.io/) instance
and an API token to upload captures to either a
[CS Personal](https://cloudshark.io/products/personal/) account or a private 
[CS Enterprise](https://cloudshark.io/products/enterprise/) instance.

To enable this script add it using the `ADDITIONAL_ARGS` after copying the
service file to `/usr/lib/systemd/system/`:

```
Environment="ADDITIONAL_ARGS=-z/usr/local/bin/cloudshark_ring_upload.sh"
```

Then copy `cloudshark.conf` to `/etc` and configure the URL and API Token. This
token will need permission to upload, search and delete.

## SELinux

Trying to use a postrotate-command caused all sorts of issues with SELinux. In
the [selinux](/selinux) has a policy module that seemed to work on CentOS 7.
