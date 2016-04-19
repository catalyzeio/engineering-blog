---
title: Hardening SSH
date: 2016-04-18
author: brandon
author_full: Brandon Maxwell
author_alt:
tags: Security, SSH, Secure Configurations
---

A critical step of securing any infrastructure includes verifying your configurations for any unnecessary or insecure defaults. One of my recent tasks after joining the team was to review configurations for any modifications to improve security, one of those being the SSH configuration. I’ve included some of my thoughts and areas you may want to focus on when reviewing your own SSH setup. Remember that securing SSH is only part of the process to achieve defense in depth of your infrastructure.

On most Linux distributions, you can find the SSH configuration file at `/etc/ssh/sshd_config` (keep in mind the file `/etc/ssh/ssh_config` is for the OpenSSH client and not the daemon). Your particular distribution may change some of the defaults, so it’s always best to review them and set the values that you prefer. Also remember to backup your current configuration before committing, and to restart your SSH daemon after making changes.


# *Defaults to Check*
These are the common defaults you will find in your `sshd_config`. These parameters can mostly be left unchanged as recommended below.

## Disallow Empty Password

If password authentication is enabled and this setting is changed to yes, users will be able to login with a null password. Changing this from the default `no` is generally **not** recommended.

	Default: PermitEmptyPasswords no

## Enforce SSH Protocol 2

SSHv1, which is now insecure, is not recommended. SSHv2 was released in 2006, and is incompatible with SSHv1. SSHv2 improvements include Diffie Hellman key exchange and strong integrity checks using message authentication codes (MAC).

	Default: Protocol 2

## Enforce Privilege Separation
	
Enabling privilege separation is a security feature to isolate processes in the event a security exploit is leveraged. Leave this parameter enabled with `yes`.

	Default: UsePrivilegeSeparation yes
		
## Use Strict Mode

Strict Mode determines whether or not SSH will check the permissions in the user’s home directory before allowing them to login, so it’s recommended to leave Strict Mode enabled. 

	Default: StrictModes yes

## Disable Challenge Response Authentication

While the name may sound more secure, it is recommended to disable Challenge Response Authentication. Enabling this option allows keyboard-interactive in SSHv2, intended primarily to allow PAM authentication.

	Default: ChallengeResponseAuthentication no

## Ignore Rhosts

In some situations Rhosts authentication can be useful, however it allows connections through the insecure r-commands. Keep the default of `yes` to ignore the user’s `.rhosts` and `.shosts` files.

	Default: IgnoreRhosts yes

---------------------------------------

# *Recommended Changes*

These are the changes that I recommend you make to your own `sshd_config` by adjusting the default parameters.

## Disable Password Authentication 

Due to the daily occurence of brute-force scanning attempts against SSH passwords, it’s recommended to disable Password Authentication. A more secure solution is to use SSH keys rather than passwords.

	Default: #PasswordAuthentication yes
	Change: PasswordAuthentication no

## Disable Root Login

With the root account comes great power, thus it’s not recommended to allow root login over SSH. A better approach is to allow normal users SSH access and to gain root level access through `su/sudo`. 

	Default: PermitRootLogin without-password
	Change: PermitRootLogin no

## Disable X11 Forwarding

In most cases, X11 Forwarding isn’t necessary, especially in the case of a server where GUI access isn’t needed. Removing unnecessary services and features is important to reducing your attack surface.

	Default: X11Forwarding yes
	Change: X11Forwarding no

## Whitelist Specific Users/Groups/Hosts

Not every user may need remote SSH access. You can allow or deny access to specific users or groups, with the latter being easier to manage. Using both AllowUsers and AllowGroups are incompatible, as AllowUsers takes precedent over AllowGroups. 

Specific hosts can also be managed in `/etc/hosts.allow` and `/etc/hosts.deny`. As a good practice, it’s recommended to disallow access from any unspecified host, and whitelist a set of specific hosts.

	Default: N/A
	Change: AllowGroups [group] [group2] or AllowUsers [name] [name2]
	DenyGroups [group] [group2] or DenyUsers [name] [name2]

---------------------------------------

# *Worth Mentioning*
## Changing the Default SSH Port (Security Through Obscurity?)

There are two sides to this argument, as some may argue changing the default port reduces your risk to automated attacks (especially unpatched zero day vulnerabilities) and reduces noise to filter when reviewing brute force attempts in your logs. Others may argue that this only achieves security through obscurity and adds complications. 

While both arguments may have valid points, keep in mind that admins may often change the default port to another easily guessable port, port 2222 or something similar. However, with this approach any user (including non-root) could potentially listen on any unprivileged port above 1024.  If you go this route, your best bet would be a rarely used well known port. Additional security options could include Fail2Ban or OSSEC Active Response to ban users making unauthorized connection attempts, or to implement port knocking for your server.

	Default: Port 22
	Change: Optional
