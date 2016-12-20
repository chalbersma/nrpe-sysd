# WFS Custom Nagios Plugin: nrpe-sysd
## Overview

This was designed to check a service or series of services running on systems utilizing SystemD (hence the "sysd"). This give us a way, through nagios, to ensure that services that should be enabled are enabled. Please make changes to the code [on our git](http://ssysrepo1/gitweb.cgi?p=nrpe-sysd.git;a=summary) and ensure any changes are made there before going elsewhere.

## Installation

Follow the `INSTALL.md` file in the `docs/` sub directory of the project.

## Recovery

Here are some errors you might see. All of the examples use `sssd.service` as the example service.

### Lockfile Warnings

When a specified lockfile exists, the check will return a warning. It's expected that there is maintenance of some sort going on and won't check the services. Instead it will return a Warning. So if you see an error like this:

<pre class="jive_text_macro jive_macro_code" jivemacro="code" ___default_attr="plain">
WARNING: Lockfile /tmp/test_lockfile exists. Stopping Checks Because of it. Will try again on next run.
</pre>

And there is no scheduled or expected maintenance, you will need to remove the lockfile and run the check again.

### Service Running but Not Enabled

If you receive this error. Your service is running but is not enable upon boot.

<pre class="jive_text_macro jive_macro_code" jivemacro="code" ___default_attr="plain">
WARNING: Service sssd.service is Running **BUT NOT ENABLED**.
</pre>

You'll want to enable the service with the following:

<pre class="jive_text_macro jive_macro_code" jivemacro="code" ___default_attr="plain">
systemctl enable sssd.service
</pre>

### Service Not Running

The check will check to see if a service is not running. When it is not it will return:

<pre class="jive_text_macro jive_macro_code" jivemacro="code" ___default_attr="plain">
CRITICAL: Service sssd.service **Not Running**
</pre>

You'll want to try and start up the service:

<pre class="jive_text_macro jive_macro_code" jivemacro="code" ___default_attr="plain">
systemctl start sssd.service
</pre>

Always check the status to ensure there are no errors. If there are you'll need to troubleshoot further.

<pre class="jive_text_macro jive_macro_code" jivemacro="code" ___default_attr="plain">
systemctl status sssd.service
</pre>

### Service Unknown

Sometimes services aren't known to systemd. That means they're not running and probably not installed.

<pre class="jive_text_macro jive_macro_code" jivemacro="code" ___default_attr="plain">
CRITICAL: sssd.service is unkmown to SystemD. sssd.service may not be installed properly.
</pre>

You'll want to re-enable the service (assuming it has a `.service` file in `/usr/lib/systemd/` somewhere). If it doesn't you'll need to install the service with `yum install service`

<pre class="jive_text_macro jive_macro_code" jivemacro="code" ___default_attr="plain">
systemctl reenable sssd.service
</pre>

Start up the service in question:

<pre class="jive_text_macro jive_macro_code" jivemacro="code" ___default_attr="plain">
systemctl start sssd.service
</pre>

As always check on it's status and ensure there are no errors.

<pre class="jive_text_macro jive_macro_code" jivemacro="code" ___default_attr="plain">
systemctl status sssd.service
</pre>

### Viewing Logs on Errors

If you find yourself with errors you may want to use a better tool to view errors or view errors going further back. You should review  this [`journalctl` guide](https://www.digitalocean.com/community/tutorials/how-to-use-journalctl-to-view-and-manipulate-systemd-logs) for a more indepth look. However, the following command should give you a reasonable insight to what you need:

<pre class="jive_text_macro jive_macro_code" jivemacro="code" ___default_attr="plain">
journalctl -u sssd.service --since today
</pre>