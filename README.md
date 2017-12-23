# Systemd Packet Capture

This is a `service` file that can be used with
[systemd](https://www.freedesktop.org/wiki/Software/systemd/)
to run a ring buffer packet capture with [tcpdump](http://www.tcpdump.org/). It
will start a packet capture and begin saving a pcap file to disk. Once that file
reaches the configured size it will begin writing packets to a new file. Then
once the maximum number of files is reached it will go back to the first file
and begin overwriting files creating a ring buffer.

## Installation

Copy the `packet-capture@.service` file to `/etc/systemd/system` and reload
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
