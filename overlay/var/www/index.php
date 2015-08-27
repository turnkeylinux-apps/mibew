<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">

<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <meta http-equiv="Content-Style-Type" content="text/css">
        <meta http-equiv="Content-Script-Type" content="text/javascript">

        <title>TurnKey Mibew</title>
        
        <link rel="stylesheet" href="css/ui.tabs.css" type="text/css" media="print, projection, screen"/>
        <link rel="stylesheet" href="css/base.css" type="text/css"/>

        <script src="js/jquery-1.2.6.js" type="text/javascript"></script>
        <script src="js/ui.core.js" type="text/javascript"></script>
        <script src="js/ui.tabs.js" type="text/javascript"></script>
        <script type="text/javascript">
            $(function() {
                $('#container-1 > ul').tabs({ fx: { opacity: 'toggle'} });
            });
        </script>
        <style>
            #mibew-chat {
                position: fixed;
                bottom: 5px;
                right: 5px;
            }
        </style>
    </head>

    <body>
        <h1>TurnKey Mibew</h1>
        
        <div id="container-1">
            <ul>
                <li><a href="#cp"><span>Control Panel</span></a></li>
            </ul>

            <div id="cp">
                <div class="fragment-content">
                    <div>
                        <a href="https://<?php print
                        $_SERVER{'HTTP_HOST'}; ?>:12320"><img
                        src="images/shell.png"/>Web Shell</a>
                    </div>
                    <div>
                        <a href="https://<?php print
                        $_SERVER{'HTTP_HOST'}; ?>:12321"><img
                        src="images/webmin.png"/>Webmin</a>
                    </div>
                    <div>
                        <a href="https://<?php print
                        $_SERVER{'HTTP_HOST'}; ?>:12322"><img
                        src="images/adminer.png"/>Adminer</a>
                    </div>
                    <div></div>
                    <div></div>

                    <h2>Getting started</h2>
                    <ul>
                        <li><p>This page is integrated with Mibew for testing (chat icon bottom right).</p></li>
                        <li><p>Log in to <a target="_blank" href="/">Mibew</a> as admin, set your status to Online and chat with yourself.</p></li>
                        <li><p>When ready, tweak the <a href="/operator/settings.php">settings</a> and copy the <a href="/operator/getcode.php">button code</a> to your production sites (make sure to select <i>Include host name into the code</i>).</p></li>
                    </ul>

                    <h2>Resources and references</h2>
                    <ul>
                        <li><p><a href="http://mibew.org">Official Mibew messenger website</a></p></li>
                        <li><p><a href="http://www.turnkeylinux.org/mibew">TurnKey Mibew release notes</a></p></li>
                    </ul>
                </div>
            </div>

        </div>

        <div id="mibew-chat">
	    <a href="/chat?locale=en" target="_blank" onclick="if(navigator.userAgent.toLowerCase().indexOf('opera') != -1 &amp;&amp; window.event.preventDefault) window.event.preventDefault();this.newWindow = window.open('/chat?locale=en&amp;url='+escape(document.location.href)+'&amp;referrer='+escape(document.referrer), 'webim', 'toolbar=0,scrollbars=0,location=0,status=1,menubar=0,width=640,height=480,resizable=1');this.newWindow.focus();this.newWindow.opener=window;return false;"><img src="/b?i=mgreen&amp;lang=en" border="0" width="163" height="61" alt=""/></a>
        </div>

    </body>
</html>
