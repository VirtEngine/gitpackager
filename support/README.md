# Support scripts

## init1.5.sh

The init1.5.sh script helps to update latest version of our cloud agent(`gulpd`) and its configuration(`gulp.conf`) file in the virtual machine images that `MegamVertice` provides auto-magically.

## To use the init1.5.sh

```bash

cd /

mkdir vertice

wget https://raw.githubusercontent.com/megamsys/gitpackager/master/support/init1.5.sh

chmod 755 init1.5.sh


```

## In the template update nsqd and cassandra ipaddress

The `init1.5.sh` is preconfigured to assume that the `nsqd` and `scylla` ip address are available locally.

```
  ### Welcome to the Gulpd configuration file.
  ###
  ### [meta]
  ###
  ### Controls the parameters for the Raft consensus group that stores metadata
  ### about the gulp.
  ###
  [meta]
    user = "root"
    nsqd = ["localhost:4150"]
    scylla = ["localhost"]
    scylla_keyspace = "vertice"
    scylla_username = "dmVydGFkbWlu"
    scylla_password = "dmVydGFkbWlu"

```

The scylla_username and scylla_password is `base64` encoded for `vertadmin`

## Support for RDNS

  The RDNS is  the resolution of an IP address to its designated domain name.

  In the opennebula template add the following

  ```
    DNS_HOSTNAME = "YES"
  ```  
 If the expected hostname is not set in the vm to check in the terminal

```
    host <ip>
```

The resolvable names of these name servers should be in the NS resource records of the zone.

Resolving an IP address uses the pointer DNS record type (PTR record)       


## In the template update gulpupd to use the correct repo

The `init1.5.sh` is preconfigured to assume you are running `testing` and `1.5` version of repository.

You can search and change the below lines.

This is needed to get timely updates on fixes to our `cloud agent(gulpd)` posted periodically in S3.

The supported branches are `testing, stable`.

```

true "${version:=1.5}"
true "${branch:=testing}"

```

## Use this common template

Please use the usual process to create a template in OpenNebula and its beyond the scope of this doc.

Make sure that the `Files = "/vertice/init1.5.sh` is configured correctly.

```
CONTEXT = [
 FILES = "/vertice/init1.5.sh",
 NETWORK = "YES",
 NODE_NAME = "$NAME",
 SET_HOSTNAME = "$NAME",
 SSH_PUBLIC_KEY = " " ]
 CPU = "0.5"
 CPU_COST = "5"
 NAME = "megam"
 DESCRIPTION = "common template for all images"
 DISK = [
 IMAGE = "megam",
 IMAGE_UNAME = "oneadmin" ]
 GRAPHICS = [
 LISTEN = "0.0.0.0",
 TYPE = "VNC" ]
 MEMORY = "1024"
 MEMORY_COST = "10"
 NIC = [
 NETWORK = "ipv4-pri",
 NETWORK_UNAME = "oneadmin" ]
 OS = [
 ARCH = "x86_64" ]
 SCHED_REQUIREMENTS = "CLUSTER_ID=\"100\""
 VCPU = "1"

```

This template when invoked by vertice, we configure the following parameters automatically to correct behaviour as chosen by the user and in configuration files like `vertice.conf`

```
CPU = "0.5"
NAME = "megam"
DISK = [
 IMAGE = "megam"]
MEMORY = "1024"
NIC = [
 NETWORK = "ipv4-pri",
 NETWORK_UNAME = "oneadmin" ]
```

The `init1.5.sh` will be executed when ever the  virtual machine boots.


### internally we use, gulpupd

This script is bundled into `init1.5.sh` as OpenNebula wants the script to be in-line and loads the full script as base64 into its memory. Hence the below copy is already there for you in `init1.5.sh`

The gulpupd script helps customers to keep the shipped images Up-to-date with the latest version of
our cloud agent (gulpd)

```bash

# updates the 1.5 version, testing repo
gulpupd --version 1.5 --branch testing

# updates the 1.5 version, stable repo
gulpupd --version 1.5 --branch stable

````

## hook_vertice.rb

hook_vertice.rb triggers MegamVertice when the virtual machine hits the following states.

`delete`, `suspend`, `poweroff`, `boot_suspend`

## To use the hook_vertice.rb

1. In your OpenNebula installation, edit the `/etc/one/oned.conf` with the following

```
VM_HOOK = [
 name      = "poweroff_hook",
 on        = "CUSTOM",
 state     = "ACTIVE",
 lcm_state = "SHUTDOWN_POWEROFF",
 command   = "hook_vertice.rb",
 arguments = "$ID $TEMPLATE poweroff stopped" ]

VM_HOOK = [
 name      = "delete_hook",
 on        = "DONE",
 command   = "hook_vertice.rb",
 arguments = "$ID $TEMPLATE destroyed destroyed" ]

VM_HOOK = [
 name      = "suspend_hook",
 on        = "CUSTOM",
 state     = "SUSPENDED",
 lcm_state = "LCM_INIT",
 command   = "hook_vertice.rb",
 arguments = "$ID $TEMPLATE suspended suspended" ]

VM_HOOK = [
 name      = "boot_suspend_hook",
 on        = "CUSTOM",
 state     = "BOOT_SUSPENDED",
 lcm_state = "RUNNING",
 command   = "hook_vertice.rb",
 arguments = "$ID $TEMPLATE running running" ]
```

2. Copy the `hook_vertice.rb` file into the location `/var/lib/one/remotes/hooks`

```

wget https://raw.githubusercontent.com/megamsys/gitpackager/master/support/hook_vertice.rb

cp hook_vertice.rb /var/lib/one/remotes/hooks

chmod 755 hook_vertice.rb

chown oneadmin:oneadmin hook_vertice.rb

```

3. Create `master_key` file into the location  /var/lib/megam
```
cat >master_key << EOF
host = 192.168.0.118:9000  // Point to your Gateway
masterkey = "3b8eb672aa7c8db82e5d34a0744740b20ed59e1f6814cfb63364040b0994ee3f"
EOF
```

## MegamVerice WHMCS Addon

1. Copy the post_billing_transaction_hook in to directory /var/www/html/whmcs/include/hooks

```bash

$ cd /var/www/html/whmcs/include/hooks

$ wget https://raw.githubusercontent.com/megamsys/gitpackager/master/support/post_billing_transaction_hook

$ sudo service apache2 restart

```

2.  Change the script to point to your gateway

3.

## letsencrypt

LetsEncrypt is a certificate authority that  provides free X.509 certificates via an automated process.

We provide a LetsEncrypt wrapper shell script which can be downloaded into any directory.

Please make sure you have a valid `public domain` and `public ip address`.


```bash

wget https://raw.githubusercontent.com/megamsys/gitpackager/master/support/letsencrypt

chmod 0755 letsencrypt

# install the letsencrypt certificate
letsencrypt --install  <domainame> <domainip>

# remove the letsencrypt certificate
letsencrypt --remove <domainname>

# renewal the letsencrypt certificate
letsencrypt --autorenew <domainname>

````
