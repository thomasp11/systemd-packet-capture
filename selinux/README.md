# SELinux

Using a postrotate command to upload captures using the
[cloudshark_ring_upload.sh)(../cloudshark_ring_upload.sh) resulted in an
SELinux Permission denied error when trying to upload the file.

I generated this SELinux policy module on CentOS 7 using 
[this documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security-enhanced_linux/sect-security-enhanced_linux-fixing_problems-allowing_access_audit2allow)
from RedHat and this seemed to work. The policy can be applied by running the
following command:

```
semodule -i systemd-packet-capture.pp
```
