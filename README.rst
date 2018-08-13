Mibew - Live Support Chat
=========================

`Mibew Messenger`_ (also known as Open Web Messenger) enables one-on-one
chat assistance in real-time directly from your website.  Just place the
button of Web Messenger at your site. Your visitors click the button and
chat with your operators who help them.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- Mibew configurations:
   
   - Installed from upstream source code to /var/www/mibew.
   - Includes TurnKey Web Control panel with embedded chat button for
     testing, and links to useful references (convenience).

     **Security note**: Updates to Mibew may require supervision so
     they **ARE NOT** configured to install automatically. See `Mibew
     documentation`_ for upgrading.

- SSL support out of the box.
- `Adminer`_ administration frontend for MySQL (listening on port
  12322 - uses SSL).
- Postfix MTA (bound to localhost) to allow sending of email (e.g.,
  password recovery).
- Webmin modules for configuring Apache2, PHP, MySQL and Postfix.

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH, MySQL: username **root**
-  Adminer: username **adminer**
-  Mibew: username **admin**


.. _Mibew Messenger: https://mibew.org/
.. _TurnKey Core: https://www.turnkeylinux.org/core
.. _Mibew documentation: https://docs.mibew.org/installation-and-update.html
.. _Adminer: https://www.adminer.org/
