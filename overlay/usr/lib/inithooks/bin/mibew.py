#!/usr/bin/python
"""Set Mibew admin password

Option:
    --pass=     unless provided, will ask interactively

"""

import sys
import getopt
import hashlib

from dialog_wrapper import Dialog
from mysqlconf import MySQL
from bcrypt import hashpw, gensalt

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

    hash = hashpw(password, saltgen()).replace('$2y$', '$2a$')

    m = MySQL()
    m.execute('UPDATE mibew.chatoperator SET vcpassword=\"%s\" WHERE vclogin=\"admin\";' % hash)


if __name__ == "__main__":
    main()

