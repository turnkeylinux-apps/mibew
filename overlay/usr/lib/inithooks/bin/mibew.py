#!/usr/bin/python
"""Set Mibew admin password

Option:
    --pass=     unless provided, will ask interactively

"""

import os
import sys
import getopt
from subprocess import Popen, PIPE, STDOUT

from dialog_wrapper import Dialog
from mysqlconf import MySQL

def usage(s=None):
    if s:
        print >> sys.stderr, "Error:", s
    print >> sys.stderr, "Syntax: %s [options]" % sys.argv[0]
    print >> sys.stderr, __doc__
    sys.exit(1)

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "h",
                                       ['help', 'pass='])
    except getopt.GetoptError, e:
        usage(e)

    password = ""
    email = ""
    for opt, val in opts:
        if opt in ('-h', '--help'):
            usage()
        elif opt == '--pass':
            password = val

    if not password:
        d = Dialog('TurnKey Linux - First boot configuration')
        password = d.get_password(
            "Mibew Password",
            "Enter new password for the Mibew 'admin' account.")

    script = '''
        $admin = operator_by_login('admin');
        $admin['vcpassword'] = calculate_password_hash('admin', '%s');
        update_operator($admin);
    '''

    DEVNULL = open(os.devnull, 'w')
    sub = Popen(['phpsh', '/var/www/mibew/index.php'], stdin = PIPE, stdout = DEVNULL, stderr = STDOUT)
    sub.communicate(script % password)
    sub.wait()
    DEVNULL.close()

if __name__ == "__main__":
    main()

