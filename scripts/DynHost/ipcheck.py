#!/usr/bin/python
import base64, getopt, urllib, httplib, os, re, sys, stat, string, time, telnetlib
try:
  import syslog
except:  # for platforms without syslog that try to use --syslog option
  class fake_syslog:
    def openlog(self,foo):
      raise Exception("Syslog not supported on this platform")
    def syslog(self,foo):
      raise Exception("Syslog not supported on this platform")
  syslog = fake_syslog()

#
# ipcheck.py  
#
# Copyright GNU GENERAL PUBLIC LICENSE Version 2
# http://www.gnu.org/copyleft/gpl.html
#
# Author  : Kal <kal@users.sourceforge.net>
#
# Acknowledgements
# ================
# 
# dyndns crew             -a great service, reliable and professional
# bgriggs@pobox.com       -ls_dyndns.py client 
# zweije@xs4all.nl        -HTTP Date header idea for wuHHMM codes 
# todd.r@rocketmail.com   -Various suggestions and Linksys support 
# yminsky@cs.cornell.edu  -syslog patch and RT311 support
# KCHANCELLOR@nc.rr.com   -RT311 tests
# Johannes Maslowski      -Draytek Vigor support
# Ulf Axelsson            -option -d fixes
# Del Hodge               -Netopia R9100 support
# Jan Bjorvik             -Cisco support
# Robert Towster          -SMC barricade
# Onno Kortmann           -acctfile security suggestion
# Greg Bentz              -Linksys fixes for firmware 1.37

#
# global constants
#
Version = "0.67"
Dyndnshost = "www.ovh.com"
Dyndnsnic = "/nic/update"
Useragent = "ipcheck/" + Version

Touchage = 25                       # days after which to force an update
Linuxip = "/sbin/ifconfig"          # ifconfig command under linux
Win32ip = "ipconfig /all"           # ipconfig command under win32

# 
# Linksys router support details from ls_dyndns.py bgriggs@pobox.com
# 
# leave Linksys_host = "" to autodetect via the default route 
# enter an ip here to skip the autodetect
# 
Linksys_host = ""
Linksys_user = " "
Linksys_page = "/Status.htm"
#password is specified by command line option -L

# 
# Netgear router support 
# 
Netgear_host = ""
Netgear_user = "admin"
Netgear_page = "/mtenSysStatus.html"
#password is specified by command line option -N

# 
# Draytek Vigor2000 router support 
# 
Draytek_host = ""
Draytek_user = "admin"
Draytek_page = "/doc/digisdn.sht"
#password is specified by command line option -D

# 
# Netopia R9100 router support 
# 
Netopia_host = ""
Netopia_user = ""
Netopia_page = "/WanEvtLog"
#password is specified by command line option -O

# 
# Cisco router support 
# uses telnet with no user name
# 
Cisco_host = ""
Cisco_user = ""
Cisco_page = ""
#password is specified by command line option -C

# 
# SMC Barricade
# 
SMC_host = ""
SMC_page = "/status.htm"
#user and password are not needed

# regular expression for address
Addressgrep = re.compile ('\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')

def Usage():
  print
  print "Usage  : ipcheck.py [options] Username Password Hostnames"
  print "or       ipcheck.py [options] --acctfile <dyndns account info file> "
  print
  print "Options:  -a address     manually specify the address "
  print "          -b             backup mx option ON (default OFF) " 
  print "          -d dir         directory for data files (default current)"
  print "          -e script      execute script after a successful update "
  print "          -f             force update regardless of current state "
  print "          -g             NAT router, let dyndns guess your IP "
  print "                         (do not use this in a cronjob, try -r) "
  print "          -h             print the detailed help text "
  print "          --help         print both usage and detailed help text "
  print "          -i interface   interface for local address (default ppp0) "
  print "          -l             log debugging text to ipcheck.log file "
  print "          --syslog       log debugging text to syslog (Unix only) "
  print "          -m mxhost      mx host to send if -b (default none) "
  print "          -o             set dyndns offline mode "
  print "          -p             proxy bypass on port 8245 "
  print "          -r URL         NAT router, use web IP detection "
  print "          -s             static dns option (default dynamic) "
  print "          -v             verbose mode "
  print "          -w             wildcard mode ON (default OFF) "
  print "          -L password    Linksys (BEFSR41) NAT router password "
  print "          -N password    Netgear (RT311) NAT router password "
  print "          -D password    Draytek (Vigor2000) NAT router password "
  print "          -O password    Netopia (R9100) NAT router password "
  print "          -C password    Cisco (667i) DSL router password "
  print "          -U username    override default NAT router username "
  print "                         leave this option out to use the default "
  print "          -S             SMC Barricade (no password needed) "
  print
  print "Note you will have to set the -i interface option if your "
  print "link to the internet is not on ppp0 (the default). "
  print
  print "Hostnames can be a comma separated list (no spaces).  Example: "
  print "python ipcheck.py username password host1.dyndns.org,host2.dyndns.org "
  print
  print "You can place your username password and hostnames in a file "
  print "(all on the first line) and use the --acctfile option if you do "
  print "not wish your password to show up on a ps. "

def Help():
  print
  print "Start ipcheck.py with no arguments to get the options screen."
  print
  print "If -f is set, all hosts will be updated regardless of the "
  print "current error, wait or IP state.  You should never need this. "
  print
  print "The file ipcheck.dat contains the IP address and hostnames "
  print "used in the last update.  If the ipcheck.dat file is older "
  print "than " + `Touchage` + " days, an update will be made to touch "
  print "the hostnames with dyndns. "
  print 
  print "The best way to run ipcheck is in the /etc/ppp/ip-up.local file "  
  print "but this won't work for many setups.  The script will run from "
  print "a cronjob.  Just make sure the hostnames are the same in each "
  print "execution.  Also, you should make sure it is ran from the same "
  print "directory each time or use the -d option to specify the directory "
  print "where data and error files should be placed. "
  print
  print "The file ipcheck.wait is created if dyndns requests a wait "
  print "before retrying.  This file will be automatically removed when "
  print "the wait is no longer in effect. "
  print
  print "The file ipcheck.err is created if dyndns responds with an error. "
  print "Ipcheck will not try to update again until this error is resolved. "
  print "You must remove the file yourself once the problem is fixed. "
  print
  print "If your ISP has a badly behaved transparent proxy on port 80 " 
  print "traffic, you can try the -p option to use port 8245. "
  print
  print "If a http message is sent to dyndns.org, the response will be "
  print "saved in the ipcheck.html file." 
  print
  print "Natively Supported NAT Routers:"
  print "Ipcheck will locate the IP of your router automatically by "
  print "looking at the default route of the machine you are running on. "
  print "Then Ipcheck will read the status page for the WAN IP address "
  print "and use that for updates.  You must specify the admin password "
  print "with the appropriate option.  Currently supported devices are: "
  print "-N netgear, -L linksys, -D draytek, -O netopia and -C cisco. "
  print
  print "If your have an unsupported device and are willing to help with "
  print "some testing, email me and I will look into adding support for it. "
  print
  print "Other NAT Routers:"
  print "You can use a specific web based IP detection via -r URL. Example:"
  print "python ipcheck.py -r checkip.dyndns.org:8245 ... "
  print "where ... = username password hostnames "
  print "Do not schedule this job more often than once every 15 mintes "
  print "because it is costing dyndns bandwidth. "
  print
  print "You can also quickly get an update done by using the -g option "
  print "to let dyndns guess your IP.  The guessed IP will be saved in the "
  print "ipcheck.dat file.  DO NOT RUN THE -g OPTION FROM A CRONJOB.  "
  print "Your local IP will not be the same as the guessed IP resulting "
  print "in abusive updates of your hostnames. "
  print
  print "Win32 Systems: "
  print "1) install python from www.python.org "
  print "2) copy the ipcheck.py file to the python directory "
  print "3) set the interface parameter to some text that appears "
  print "before the correct address in the output of ipconfig /all "
  print
  print "For example you can use the model name or the mac address: "
  print "python ipcheck.py -i LNE100TX username password hostname "
  print "python ipcheck.py -i 4A-C9-1F-3E-A3-E7 username password hostname "
  print
  print "The ipcheck homepage can be found at:"
  print "http://ipcheck.sourceforge.net/"
  print
  print "Client development information can be found at:"
  print "http://support.dyndns.org/dyndns/clients/devel/"


    
class Logger:
  #
  # open a new log file in the target dir if logging
  # a race condition if there are tons of scripts
  # starting at the same time and should really use locking
  # but that would be overkill for this app
  #
  def __init__(self, logname = "ipcheck.log", verbose = 0, logging = 0, use_syslog = 0):
    self.logname = logname
    self.verbose = verbose
    self.logging = logging
    self.syslog = use_syslog
    self.prefix = "ipcheck.py: "

    if self.syslog == 1:
      syslog.openlog("ipcheck")
    if self.logging == 1:
      self.logfp = open(self.logname, "w")
      self.logfp.write(Useragent + "\n")
      self.logfp.write(self.prefix + "logging to " + self.logname + "\n")
      self.logfp.close()

  # normal logging message
  def logit(self, logline):
    if self.verbose:
      print self.prefix + logline
    if self.logging:
      self.logfp = open(self.logname, "a")
      self.logfp.write(self.prefix + logline + "\n")
      self.logfp.close()
    if self.syslog:
      syslog.syslog(logline)

  # logging message that gets printed even if not verbose
  def logexit(self, logline):
    print self.prefix + logline
    if self.logging:
      self.logfp = open(self.logname, "a")
      self.logfp.write(self.prefix + logline + "\n")
      self.logfp.close()
    if self.syslog:
      syslog.syslog(logline)


def DefaultRoute(logger, Tempfile):
  iphost = ""
  if sys.platform == "win32":
    logger.logit("WIN32 default route detection for router.")
    os.system ("route print " + " > " + Tempfile)
    fp = open(Tempfile, "r")
    while 1:
      fileline = fp.readline()
      if not fileline:
        fp.close()
        break
      p1 = string.find(fileline, "0.0.0.0")
      if p1 != -1:
        #
        # replacing findall to support older python 1.5.1 sites
        #
        #ipmatch = Addressgrep.findall(fileline)
        #if ipmatch != None:
        #  if len(ipmatch) > 2:
        #    iphost = ipmatch[2]

        ipmatch = Addressgrep.search(fileline)
        ip1 = ipmatch.group()
        p1 = string.find(fileline, ip1) + len(ip1)
        ipmatch = Addressgrep.search(fileline, p1)
        ip2 = ipmatch.group()
        p2 = string.find(fileline, ip2) + len(ip2)
        ipmatch = Addressgrep.search(fileline, p2)
        iphost = ipmatch.group()
  else:
    logger.logit("Linux default route detection for router.")
    os.system ("/sbin/route -n " + " > " + Tempfile)
    fp = open(Tempfile, "r")
    while 1:
      fileline = fp.readline()
      if not fileline:
        fp.close()
        break
      p1 = string.find(fileline, "UG")
      if p1 != -1:
        #
        # replacing findall to support older python 1.5.1 sites
        #
        #ipmatch = Addressgrep.findall(fileline)
        #if ipmatch != None:
        #  if len(ipmatch) > 1:
        #    iphost = ipmatch[1]

        ipmatch = Addressgrep.search(fileline)
        ip1 = ipmatch.group()
        p1 = string.find(fileline, ip1) + len(ip1)
        ipmatch = Addressgrep.search(fileline, p1)
        iphost = ipmatch.group()

  return iphost


if __name__=="__main__":

  #
  # default options
  #
  opt_address = ""
  opt_force = 0
  opt_logging = 0
  opt_syslog  = 0
  opt_verbose = 0
  opt_hostnames = ""
  opt_interface = "ppp0"
  opt_username = ""
  opt_password = ""
  opt_static = 0
  opt_wildcard = 0
  opt_backupmx = 0
  opt_mxhost = ""
  opt_proxy = 0
  opt_router = ""
  opt_guess = 0
  opt_offline = 0
  opt_execute = ""
  opt_directory = ""
  opt_acctfile = ""
  opt_natuser = ""
  opt_Linksys_password = ""
  opt_Netgear_password = ""
  opt_Draytek_password = ""
  opt_Netopia_password = ""
  opt_Cisco_password = ""
  opt_SMC_router = 0

  #
  # parse the command line options
  #
  if len(sys.argv) == 1:
    Usage()
    sys.exit(0)
  
  try:
    opts, args = getopt.getopt(sys.argv[1:], "a:bd:e:hi:flm:pr:svwgL:oN:U:D:O:C:S", ["syslog", "acctfile=", "help"])
  except getopt.error, reason:
    print reason
    sys.exit(-1)

  #
  # check verbose, logging and detailed help options first
  # check directory to place logging file
  #
  for opt in opts:
    (lopt, ropt) = opt
    if lopt == "-l":
      opt_logging = 1
    elif lopt == "--syslog":
      opt_syslog = 1
    elif lopt == "-v":
      opt_verbose = 1
    elif lopt == "--help":
      Usage()
      Help()
      sys.exit(0)
    elif lopt == "-h":
      Help()
      sys.exit(0)
    elif lopt == "-d":
      if os.path.isdir(ropt):
        opt_directory = ropt
      else:
        print "bad directory option"
        sys.exit()

      # fix the dir name to end in slash
      if opt_directory[-1:] != "/":
        opt_directory = opt_directory + "/"

  #
  # create the logger object
  #
  if opt_directory == "":
    logger = Logger("ipcheck.log", opt_verbose, opt_logging, opt_syslog)
  else:
    logger = Logger(opt_directory + "ipcheck.log", opt_verbose, opt_logging, opt_syslog)
    logline = "opt_directory set to " + opt_directory
    logger.logit(logline)

  #
  # check acctfile option
  #
  for opt in opts:
    (lopt, ropt) = opt
    if lopt == "--acctfile":
      opt_acctfile = ropt
      logline = "opt_acctfile set to " + opt_acctfile
      logger.logit(logline)

  if len(args) != 3 and opt_acctfile == "":
    Usage()
    sys.exit(0)

  #
  # okay now parse rest of the options and log as needed
  #
  for opt in opts:
    (lopt, ropt) = opt
    if lopt == "-a":
      opt_address = ropt
      logline = "opt_address set to " + opt_address
      logger.logit(logline)
    elif lopt == "-i":
      opt_interface = ropt
      logline = "opt_interface set to " + opt_interface
      logger.logit(logline)
    elif lopt == "-f":
      opt_force = 1
      logline = "opt_force set " 
      logger.logit(logline)
    elif lopt == "-w":
      opt_wildcard = 1
      logline = "opt_wildcard set " 
      logger.logit(logline)
    elif lopt == "-s":
      opt_static = 1
      logline = "opt_static set " 
      logger.logit(logline)
    elif lopt == "-b":
      opt_backupmx = 1
      logline = "opt_backupmx set " 
      logger.logit(logline)
    elif lopt == "-p":
      opt_proxy = 1
      logline = "opt_proxy set " 
      logger.logit(logline)
    elif lopt == "-m":
      opt_mxhost = ropt
      logline = "opt_mxhost set to " + opt_mxhost
      logger.logit(logline)
    elif lopt == "-r":
      opt_router = ropt
      logline = "opt_router set to " + opt_router
      logger.logit(logline)
    elif lopt == "-g":
      opt_guess = 1
      logline = "opt_guess set " 
      logger.logit(logline)
    elif lopt == "-o":
      opt_offline = 1
      logline = "opt_offline set " 
      logger.logit(logline)
    elif lopt == "-e":
      opt_execute = ropt
      logline = "opt_execute set to " + opt_execute
      logger.logit(logline)
    elif lopt == "-U":
      opt_natuser = ropt
      logline = "opt_natuser set to " + opt_natuser
      logger.logit(logline)
      Linksys_user = opt_natuser
      Netgear_user = opt_natuser
      Draytek_user = opt_natuser
      Netopia_user = opt_natuser
      Cisco_user = opt_natuser
    elif lopt == "-L":
      opt_Linksys_password = ropt
      logline = "opt_Linksys_password = "
      for x in xrange(0, len(ropt)):
        logline = logline + "*"
      logger.logit(logline)
    elif lopt == "-N":
      opt_Netgear_password = ropt
      logline = "opt_Netgear_password = "
      for x in xrange(0, len(ropt)):
        logline = logline + "*"
      logger.logit(logline)
    elif lopt == "-D":
      opt_Draytek_password = ropt
      logline = "opt_Draytek_password = "
      for x in xrange(0, len(ropt)):
        logline = logline + "*"
      logger.logit(logline)
    elif lopt == "-O":
      opt_Netopia_password = ropt
      logline = "opt_Netopia_password = "
      for x in xrange(0, len(ropt)):
        logline = logline + "*"
      logger.logit(logline)
    elif lopt == "-C":
      opt_Cisco_password = ropt
      logline = "opt_Cisco_password = "
      for x in xrange(0, len(ropt)):
        logline = logline + "*"
      logger.logit(logline)
    elif lopt == "-S":
      opt_SMC_router = 1
      logline = "opt_SMC_router set " 
      logger.logit(logline)


  #
  # store the command line arguments
  #
  if opt_acctfile != "":
    try:
      fp = open (opt_acctfile, "r")
      acctdata = fp.read()
      fp.close()
    except:
      logline = "Bad acctfile: " + opt_acctfile
      logger.logexit(logline)
      sys.exit(-1)
    args = string.split(acctdata)

  opt_username = args[0] 
  logline = "opt_username = " + opt_username
  logger.logit(logline)

  opt_password = args[1] 
  logline = "opt_password = " 
  for x in xrange(0, len(opt_password)):
    logline = logline + "*"
  logger.logit(logline)

  opt_hostnames = args[2] 
  logline = "opt_hostnames = " + opt_hostnames
  logger.logit(logline)
  hostnames = string.split(opt_hostnames, ",")
    


  #
  # taint check, make sure each hostname is a dotted fqdn
  #
  for host in hostnames:
    if string.find(host, ".") == -1:
      logline = "Bad hostname: " + host
      logger.logexit(logline)
      sys.exit(-1)

  #
  # taint check the mx host
  #
  if opt_mxhost != "":
    if string.find(opt_mxhost, ".") == -1:
      logline = "Bad mxhost: " + opt_mxhost
      logger.logexit(logline)
      sys.exit(-1)

  #
  # create the full path names
  #
  Datfile = "ipcheck.dat"
  if opt_directory != "":
    Datfile = opt_directory + Datfile
  Errfile = "ipcheck.err"
  if opt_directory != "":
    Errfile = opt_directory + Errfile
  Waitfile = "ipcheck.wait"
  if opt_directory != "":
    Waitfile = opt_directory + Waitfile
  Htmlfile = "ipcheck.html"
  if opt_directory != "":
    Htmlfile = opt_directory + Htmlfile
  Tempfile = "ipcheck.tmp"
  if opt_directory != "":
    Tempfile = opt_directory + Tempfile
  
  

  #
  # determine the local machine's ip
  #
  localip = ""
  if opt_address != "":
    logger.logit("manually setting localip")
    localip = opt_address
  elif opt_SMC_router != 0:
    # 
    # SMC barricade router ip detection
    # 
    ipdir = SMC_page

    #
    # determine the router host address
    # 
    iphost = ""
    if SMC_host != "":
      logger.logit("SMC_host set explicitly.")
      iphost = SMC_host
    else:
      iphost = DefaultRoute(logger, Tempfile)

    if iphost == "":
      logger.logit("No router ip detected.  Assuming 192.168.0.254")
      iphost = "192.168.0.254"
    else:
      logline = "Trying router at " + iphost
      logger.logit(logline)

    # connect to the router's admin webpage
    try:
      ipurl = "http://" + iphost + SMC_page
      urlfp = urllib.urlopen(ipurl)
      ipdata = urlfp.read()
      urlfp.close()
    except:
      logline = "No address found on router at " + iphost
      logger.logexit(logline)
      sys.exit(-1)

    # create an output file of the response
    filename = "smc.html"
    if opt_directory != "":
      filename = opt_directory + filename
    fp = open(filename, "w")
    fp.write(ipdata)
    fp.close()
    logger.logit("smc.html file created")

    # grab first thing that looks like an IP address
    ipmatch = Addressgrep.search(ipdata)
    if ipmatch != None:
      localip = ipmatch.group()

    if localip == "0.0.0.0":
      logline = "The router has no WAN IP assigned. " 
      logger.logexit(logline)
      sys.exit(-1)

    if localip == "":
      logline = "No address found on router " 
      logger.logexit(logline)
      sys.exit(-1)

  elif opt_Cisco_password != "":
    # 
    # Cisco router ip detection
    # 
    ipdir = Cisco_page

    #
    # determine the router host address
    # 
    iphost = ""
    if Cisco_host != "":
      logger.logit("Cisco_host set explicitly.")
      iphost = Cisco_host
    else:
      iphost = DefaultRoute(logger, Tempfile)

    if iphost == "":
      logger.logit("No router ip detected.  Assuming 192.168.10.5")
      iphost = "192.168.10.5"
    else:
      logline = "Trying router at " + iphost
      logger.logit(logline)

    # connect to the router's admin webpage
    try:
     tn = telnetlib.Telnet(iphost)
     logger.logit("Creating telnetlib obj done")
     tn.read_until("assword:")
     logger.logit("Password prompt found")
     tn.write(opt_Cisco_password + "\r\n")
     logger.logit("opt_Cisco_password sent")
     tn.write("show er\r\n")
     logger.logit("show er sent")
     tn.write("exit\r\n")
     logger.logit("exit sent")
     ipdata = tn.read_until("Total Number", 1000)
     logger.logit("ipdata read")

    except:
      logline = "No address found on router at " + iphost
      logger.logexit(logline)
      sys.exit(-1)

    # create an output file of the response
    filename = "cisco.html"
    if opt_directory != "":
      filename = opt_directory + filename
    fp = open(filename, "w")
    fp.write(ipdata)
    fp.close()
    logger.logit("cisco.html file created")

    # look for the negotiated IP in the log
    p1 = string.rfind(ipdata, "Negotiated IP Address")
    if p1 != -1:
      ipmatch = Addressgrep.search(ipdata, p1)
      if ipmatch != None:
        localip = ipmatch.group()

    if localip == "0.0.0.0":
      logline = "The router has no WAN IP assigned. " 
      logger.logexit(logline)
      sys.exit(-1)

    if localip == "":
      logline = "No address found on router with password " + opt_Cisco_password
      logger.logexit(logline)
      sys.exit(-1)

  elif opt_Netopia_password != "":
    # 
    # Netopia router ip detection
    # 
    ipdir = Netopia_page

    #
    # determine the router host address
    # 
    iphost = ""
    if Netopia_host != "":
      logger.logit("Netopia_host set explicitly.")
      iphost = Netopia_host
    else:
      iphost = DefaultRoute(logger, Tempfile)

    if iphost == "":
      logger.logit("No router ip detected.  Assuming 192.168.0.1")
      iphost = "192.168.0.1"
    else:
      logline = "Trying router at " + iphost
      logger.logit(logline)

    # connect to the router's admin webpage
    try:
      h1 = httplib.HTTP(iphost)

      h1.putrequest("GET", Netopia_page)
      h1.putheader("USER-AGENT", Useragent)
      authstring = base64.encodestring(Netopia_user + ":" + opt_Netopia_password)
      authstring = string.replace(authstring, "\012", "")
      h1.putheader("AUTHORIZATION", "Basic " + authstring)
      h1.endheaders()
      errcode, errmsg, headers = h1.getreply()
      fp = h1.getfile()
      ipdata = fp.read()
      fp.close()
    except:
      logline = "No address found on router at " + iphost
      logger.logexit(logline)
      sys.exit(-1)

    # create an output file of the response
    filename = "netopia.html"
    if opt_directory != "":
      filename = opt_directory + filename
    fp = open(filename, "w")
    fp.write(ipdata)
    fp.close()
    logger.logit("netopia.html file created")

    # look for local ip in the log
    p1 = string.find(ipdata, "local")
    if p1 != -1:
      ipmatch = Addressgrep.search(ipdata, p1)
      if ipmatch != None:
        localip = ipmatch.group()

    if localip == "0.0.0.0":
      logline = "The router has no WAN IP assigned. " 
      logger.logexit(logline)
      sys.exit(-1)

    if localip == "":
      logline = "No address found on router with password " + opt_Netopia_password
      logger.logexit(logline)
      sys.exit(-1)

  elif opt_Draytek_password != "":
    # 
    # Draytek router ip detection
    # 
    ipdir = Draytek_page

    #
    # determine the router host address
    # 
    iphost = ""
    if Draytek_host != "":
      logger.logit("Draytek_host set explicitly.")
      iphost = Draytek_host
    else:
      iphost = DefaultRoute(logger, Tempfile)

    if iphost == "":
      logger.logit("No router ip detected.  Assuming 192.168.1.1")
      iphost = "192.168.1.1"
    else:
      logline = "Trying router at " + iphost
      logger.logit(logline)

    # connect to the router's admin webpage
    try:
      h1 = httplib.HTTP(iphost)

      h1.putrequest("GET", Draytek_page)
      h1.putheader("USER-AGENT", Useragent)
      authstring = base64.encodestring(Draytek_user + ":" + opt_Draytek_password)
      authstring = string.replace(authstring, "\012", "")
      h1.putheader("AUTHORIZATION", "Basic " + authstring)
      h1.endheaders()
      errcode, errmsg, headers = h1.getreply()
      fp = h1.getfile()
      ipdata = fp.read()
      fp.close()
    except:
      logline = "No address found on router at " + iphost
      logger.logexit(logline)
      sys.exit(-1)

    # create an output file of the response
    filename = "draytek.html"
    if opt_directory != "":
      filename = opt_directory + filename
    fp = open(filename, "w")
    fp.write(ipdata)
    fp.close()
    logger.logit("draytek.html file created")

    # grab first thing that looks like an IP address
    ipmatch = Addressgrep.search(ipdata)
    if ipmatch != None:
      localip = ipmatch.group()

    if localip == "0.0.0.0":
      logline = "The router has no WAN IP assigned. " 
      logger.logexit(logline)
      sys.exit(-1)

    if localip == "":
      logline = "No address found on router with password " + opt_Draytek_password
      logger.logexit(logline)
      sys.exit(-1)

  elif opt_Netgear_password != "":
    # 
    # Netgear router ip detection
    # 
    ipdir = Netgear_page

    #
    # determine the router host address
    # 
    iphost = ""
    if Netgear_host != "":
      logger.logit("Netgear_host set explicitly.")
      iphost = Netgear_host
    else:
      iphost = DefaultRoute(logger, Tempfile)

    if iphost == "":
      logger.logit("No router ip detected.  Assuming 192.168.0.1")
      iphost = "192.168.0.1"
    else:
      logline = "Trying router at " + iphost
      logger.logit(logline)

    # connect to the router's admin webpage
    try:
      h1 = httplib.HTTP(iphost)

      h1.putrequest("GET", Netgear_page)
      h1.putheader("USER-AGENT", Useragent)
      authstring = base64.encodestring(Netgear_user + ":" + opt_Netgear_password)
      authstring = string.replace(authstring, "\012", "")
      h1.putheader("AUTHORIZATION", "Basic " + authstring)
      h1.endheaders()
      errcode, errmsg, headers = h1.getreply()
      fp = h1.getfile()
      ipdata = fp.read()
      fp.close()
    except:
      logline = "No address found on router at " + iphost
      logger.logexit(logline)
      sys.exit(-1)

    # create an output file of the response
    filename = "netgear.html"
    if opt_directory != "":
      filename = opt_directory + filename
    fp = open(filename, "w")
    fp.write(ipdata)
    fp.close()
    logger.logit("netgear.html file created")

    # look for the WAN Port in the log
    p1 = string.rfind(ipdata, "WAN Port")
    if p1 != -1:
      ipmatch = Addressgrep.search(ipdata, p1)
      if ipmatch != None:
        localip = ipmatch.group()

    if localip == "0.0.0.0":
      logline = "The router has no WAN IP assigned. " 
      logger.logexit(logline)
      sys.exit(-1)

    if localip == "":
      logline = "No address found on router with password " + opt_Netgear_password
      logger.logexit(logline)
      sys.exit(-1)

  elif opt_Linksys_password != "":
    # 
    # Linksys router ip detection
    # 
    ipdir = Linksys_page

    #
    # determine the linksys router host address
    # 
    iphost = ""
    if Linksys_host != "":
      logger.logit("Linksys_host set explicitly.")
      iphost = Linksys_host
    else:
      iphost = DefaultRoute(logger, Tempfile)

    if iphost == "":
      logger.logit("No router ip detected.  Assuming 192.168.1.1")
      iphost = "192.168.1.1"
    else:
      logline = "Trying linksys router at " + iphost
      logger.logit(logline)

    # connect to the router's admin webpage
    try:
      h1 = httplib.HTTP(iphost)

      #
      # Hack from ls_dyndns.py for authorization.
      #
      # For some reason the dyndns router won't authenticate when
      # using standard headers for authorization.  Like this:
      #
      #h1.putrequest('GET', ipdir)
      #authstring = base64.encodestring(Linksys_user + ":" + opt_Linksys_password)
      #h1.putheader("Authorization", "Basic " + authstring)
      #
      # It may be looking for lines that end with just \n not \r\n.
      # Anyways here is the snip from ls_dyndns.py
      #
      # Note:  Modified by Greg Bentz.
      #        Linksys firmware 1.37, doesn't like the trailing \n on the authstring.
      #        Also requires "\r\n".
      #        My theory concerning the standard headers is that the Linksys header
      #        parsing requires all the header info to appear in one packet.
      #        Use of an extra putheader() call puts the authorization information into
      #        a second packet which is not read by the Linksys device.
      #
      authstring = base64.encodestring(Linksys_user + ":" + opt_Linksys_password)
      authstring = string.replace(authstring, "\012", "")
      ipdir = Linksys_page + ' \r\n' \
        + 'Authorization: Basic ' \
        + authstring + '\r\n'
      h1.putrequest('GET', ipdir)

      h1.endheaders()

      errcode, errmsg, headers = h1.getreply()
      fp = h1.getfile()
      ipdata = fp.read()
      fp.close()
    except:
      logline = "No address found on router at " + iphost
      logger.logexit(logline)
      sys.exit(-1)


    # create an output file of the linksys response
    filename = "linksys.html"
    if opt_directory != "":
      filename = opt_directory + filename
    fp = open(filename, "w")
    fp.write(ipdata)
    fp.close()
    logger.logit("linksys.html file created")

    #
    # replacing findall to support older python 1.5.1 sites
    #
    #ipmatch = Addressgrep.findall(ipdata)
    #if ipmatch != None:
    #  if len(ipmatch) > 2:
    #    localip = ipmatch[2]

    ipmatch = Addressgrep.search(ipdata)
    ip1 = ipmatch.group()
    p1 = string.find(ipdata, ip1) + len(ip1)
    ipmatch = Addressgrep.search(ipdata, p1)
    ip2 = ipmatch.group()
    p2 = string.find(ipdata, ip2) + len(ip2)
    ipmatch = Addressgrep.search(ipdata, p2)
    localip = ipmatch.group()

    if localip == "0.0.0.0":
      logline = "The router has no WAN IP assigned. " 
      logger.logexit(logline)
      sys.exit(-1)

    if localip == "":
      logline = "No address found on router with password " + opt_Linksys_password
      logger.logexit(logline)
      sys.exit(-1)

  elif opt_router != "":
    logger.logit("web based ip detection for localip")
    ipurl = ""

    # check for deprecated url
    if string.find(opt_router, "cgi-bin/check_ip.cgi") != -1:
      logger.logexit("You should be using -r checkip.dyndns.org ")
      logger.logexit("Continuing with new URL.")
      opt_router = "checkip.dyndns.org:8245"
    
    # strip off the http part, if any
    if opt_router[:7] == "HTTP://" or opt_router[:7] == "http://":
      ipurl = opt_router[7:]
    else:
      ipurl = opt_router

    # stick it back on for urllib usage
    ipurl = "http://" + ipurl

    logger.logit("trying URL " + ipurl)

    # grab the data
    try:
      urlfp = urllib.urlopen(ipurl)
      ipdata = urlfp.read()
      urlfp.close()
    except:
      logline = "Unable to open url " + ipurl
      logger.logexit(logline)
      sys.exit(-1)


    # create an output file of the ip detection response
    filename = "webip.html"
    if opt_directory != "":
      filename = opt_directory + filename
    fp = open(filename, "w")
    fp.write(ipdata)
    fp.close()
    logger.logit("webip.html file created")

    # grab first thing that looks like an IP address
    ipmatch = Addressgrep.search(ipdata)
    if ipmatch != None:
      localip = ipmatch.group()
      logger.logit("webip detected = " + localip)

    if localip == "":
      logline = "No address found at " + opt_router
      logger.logexit(logline)
      sys.exit(-1)

  else:
    logger.logit("interface ip detection for localip")

    if sys.platform == "win32":
      localip = ""
      getip = Win32ip 
      os.system (getip + " > " + Tempfile)
      fp = open(Tempfile, "r")
      ipdata = fp.read()
      fp.close()
      # grab the first dotted quad after the interface
      p1 = string.find(ipdata, opt_interface)
      if p1 != -1:
        ipmatch = Addressgrep.search(ipdata, p1)
        if ipmatch != None:
          localip = ipmatch.group()

    else:
      getip = Linuxip + " " + opt_interface
      os.system (getip + " > " + Tempfile)
      fp = open(Tempfile, "r")
      ipdata = fp.read()
      fp.close()
      # grab the first dotted quad after the interface
      p1 = string.find(ipdata, opt_interface)
      if p1 != -1:
        ipmatch = Addressgrep.search(ipdata, p1)
        if ipmatch != None:
          localip = ipmatch.group()

    if localip == "":
      logline = "No address found on interface " + opt_interface
      logger.logexit(logline)
      sys.exit(-1)

  #
  # check the IP to make sure it is sensible
  #
  p1 = string.find(localip, ".")
  p2 = string.find(localip, ".", p1+1)
  p3 = string.find(localip, ".", p2+1)
  p4 = string.find(localip, ".", p3+1)
  if p1 == -1 or p2 == -1 or p3 == -1 or p4 != -1:
    logline = "Invalid local address " + localip
    logger.logexit(logline)
    sys.exit(-1)
  
  try:
    ip1 = string.atoi(localip[0:p1])
    ip2 = string.atoi(localip[p1+1:p2])
    ip3 = string.atoi(localip[p2+1:p3])
    ip4 = string.atoi(localip[p3+1:])
  except:
    ip1 = 0
    ip2 = 0
    ip3 = 0
    ip4 = 0
    # 0-255 in first three allowed, 0 to 254 in last 
  if ip1 < 0 or ip1 > 255 or ip2 < 0 or ip2 > 255 or ip3 < 0 or ip3 > 255 or ip4 < 0 or ip4 > 254:
    logline = "Invalid local address " + localip
    logger.logexit(logline)
    sys.exit(-1)

  #
  # read the data from file of last update, if any
  #
  fileip = ""
  filehosts = []
  fileage = 0
  try:
    fp = open (Datfile, "r")
    fileip = fp.readline()
    if fileip[-1] == "\n": 
      fileip = fileip[:-1]
    while 1:
      fileline = fp.readline()
      if not fileline:
        break
      filehosts.append(fileline[:-1])
    fp.close()
    
    #
    # get the age of the file
    #
    currtime = time.time()
    statinfo = os.stat(Datfile)
    fileage = (currtime - statinfo[8]) / (60*60*24)

  except:
    logger.logit("No ipcheck.dat file.")

  #
  # read the data from error file, if any
  #
  errors = []
  try:
    fp = open (Errfile, "r")
    while 1:
      errline = fp.readline()
      if not errline:
        break
      errors.append(errline[:-1])
    fp.close()
  except:
    logger.logit("Good, no ipcheck.err file.")

  if len(errors) > 0 and opt_force == 0:
    logger.logit("Handling errors in ipcheck.err file.")
    for err in errors:
      errlist = string.split(err, " ")
      if string.find(err, "badauth") == 0:
        logger.logit("badauth found.")
        if errlist[1] == opt_username and errlist[2] == opt_password:
          logger.logexit("Previous authorization error encountered for")
          logger.logexit("Username:" + opt_username)
          logger.logexit("Password:" + opt_password)
          logger.logexit("Erase the ipcheck.err file if this is correct now.")
          sys.exit(-1)
        else:
          logger.logit("trying new username or password.")
          logger.logit("ipcheck.err file removed and continuing.")
          os.unlink (Errfile)
      elif string.find(err, "badsys") == 0:
        logger.logit("badsys found.")
        logger.logexit("Previous system error encountered for " + errlist[1])
        logger.logexit("Erase the ipcheck.err file if this is correct now.")
        sys.exit(-1)
      elif string.find(err, "badagent") == 0:
        logger.logit("badagent found.")
        logger.logexit("Badagent contact author at kal@users.sourceforge.net.")
        sys.exit(-1)
      elif string.find(err, "shutdown") == 0:
        logger.logit("shutdown found.")
        logger.logexit("Service shutdown from dyndns.org")
        logger.logexit("Check http://www.dyndns.org/status.shtml")
        logger.logexit("Erase the ipcheck.err file when shutdown is over.")
        sys.exit(-1)
      elif string.find(err, "abuse") == 0:
        logger.logit("abuse found.")
        if errlist[1] in hostnames:
          logger.logexit("Previous abuse lockout encountered for " + errlist[1])
          logger.logexit("Use the form at http://support.dyndns.org/dyndns/abuse.shtml")
          logger.logexit("Erase the ipcheck.err file when dyndns notifies you (by email).") 
          sys.exit(-1)
      elif string.find(err, "notfqdn") == 0:
        logger.logit("notfqdn found.")
        if errlist[1] in hostnames:
          logger.logexit("Previous notfqdn encountered for host:" + errlist[1])
          logger.logexit("Erase the ipcheck.err file if this is really correct.")
          sys.exit(-1)
      elif string.find(err, "!donator") == 0:
          logger.logexit("Previous !donator encountered for " + errlist[1])
          logger.logexit("Erase the ipcheck.err file when this problem is fixed.") 
          logger.logexit(logline)
          sys.exit(-1)
      elif string.find(err, "nohost") == 0:
        logger.logit("nohost found.")
        if errlist[1] in hostnames:
          logger.logexit("Previous nohost encountered for " + errlist[1])
          logger.logexit("You may be trying -s for a dynamic host or vice versa.")
          logger.logexit("Erase the ipcheck.err if file this host is now created.")
          sys.exit(-1)
      elif string.find(err, "!yours") == 0:
        logger.logit("!yours found.")
        if errlist[1] in hostnames:
          logger.logexit("Previous !yours encountered for " + errlist[1])
          logger.logexit("Erase the ipcheck.err file when the problem is fixed.")
          sys.exit(-1)
      elif string.find(err, "numhost") == 0:
        logger.logit("numhost found.")
        logger.logexit("Contact support@dyndns.org about numhost error.")
        logger.logexit("Attach the ipcheck.html file for details.")
        logger.logexit("Erase the ipcheck.err file when the problem is fixed.")
        sys.exit(-1)
      elif string.find(err, "dnserr") == 0:
        logger.logit("numhost found.")
        logger.logexit("Contact support@dyndns.org about dnserr error.")
        logger.logexit("Attach the ipcheck.html file for details.")
        logger.logexit("Erase the ipcheck.err file when the problem is fixed.")
        sys.exit(-1)
      else:
        logger.logexit("Unrecognized error in ipcheck.err file.")
        logger.logexit("Erase the ipcheck.err if there is no problem.")
        sys.exit(-1)

  #
  # read the data from wait file, if any
  #
  waitcode = ""
  waitdate = ""
  try:
    fp = open (Waitfile, "r")
    waitcode = fp.readline()
    if waitcode[-1] == "\n": 
      waitcode = waitcode[:-1]
    waitdate = fp.readline()
    if waitdate[-1] == "\n": 
      waitdate = waitdate[:-1]
    fp.close()
  except:
    logger.logit("Good, no ipcheck.wait file.")

  if waitcode != "" and opt_force == 0:

    logger.logit("Found wait entry.")
    logger.logit(waitcode)
    logger.logit(waitdate)

    #
    # first line is the code
    # second line is time.time() when the code was received
    # now determine whether we should continue or abort
    # remove the file if the wait is no longer needed
    #
    try:
      waitnum = string.atof(waitdate)
    except:
      waitnum = 0.0

    if waitnum == 0.0:
      logger.logit("Invalid wait date in ipcheck.wait file.")
      logger.logit("ipcheck.wait file removed and continuing.")
      os.unlink (Waitfile)

    elif waitcode[0] == 'u':
      # wait until GMT
      logger.logit("Decoding wait until entry in ipcheck.wait file.")

      # First we check the age of the file.
      currtime = time.time()
      statinfo = os.stat(Waitfile)
      if (currtime - statinfo[8]) / (60*60) > 24:
        # the file is older than 24 hours and should be ignored
        logger.logit("Stale ipcheck.wait file removed and continuing.")
        os.unlink (Waitfile)
      elif (currtime - waitnum) / (60*60) > 24:
        # the code is older than 24 hours and should be ignored
        logger.logit("Stale code in file removed and continuing.")
        os.unlink (Waitfile)
      else:
        try:
          waitsec = string.atoi(waitcode[2:])
        except:
          waitsec = 0

        currtime = time.time()
        if currtime > waitnum + waitsec:
          logger.logit("until wait entry expired.")
          logger.logit("ipcheck.wait file removed and continuing.")
          os.unlink (Waitfile)
        else:
          logger.logit("until wait entry in effect: quietly aborting.")
          sys.exit(-1)
  
    else:
      # wait h, m or s
      logger.logit("Decoding hms entry in ipcheck.wait file.")
      try:
        waitsec = string.atoi(waitcode[1:3])
        if waitcode[3] == 'h' or waitcode[3] == 'H':
          waitsec = waitsec * 60 * 60
        elif waitcode[3] == 'm' or waitcode[3] == 'M':
          waitsec = waitsec * 60 
      except:
        waitsec = 0

      currtime = time.time()
      if currtime > waitnum + waitsec:
        logger.logit("hms wait entry expired.")
        logger.logit("ipcheck.wait file removed and continuing.")
        os.unlink (Waitfile)
      else:
        logger.logit("hms wait entry in effect: quietly aborting.")
        sys.exit(-1)

  #
  # determine whether and which hosts need updating
  #
  updatehosts = []

  # if opt_force is set then update all hosts
  # or offline mode selected
  if opt_force == 1 or opt_offline:
    logger.logit("Updates forced by -f option.")
    for host in hostnames:
      updatehosts.append(host)

  # else if file age is older than update all hosts
  elif fileage > Touchage:
    logger.logit("Updates required by stale ipcheck.dat file.")
    for host in hostnames:
      updatehosts.append(host)

  # else check the address used in last update
  elif localip != fileip:
    logger.logit("Updates required by ipcheck.dat address mismatch.")
    for host in hostnames:
      updatehosts.append(host)

  # check each hostname to see if the last update was the same address
  else:
    logger.logit("Checking hosts in file vs command line.")
    updateflag = 0
    for host in hostnames:
      if host not in filehosts:
        updateflag = 1

    # If anyone of the hosts on the command line need updating,
    # put them all in the updatehosts list so they will get the
    # same last updated timestamp at dyndns.  This way they all 
    # won't need to be touched again for Touchage days, instead 
    # of having multiple touches for different last updated dates.
    if updateflag == 1:
      for host in hostnames:
        updatehosts.append(host)

  if updatehosts == []:
    # Quietly log this message then exit too.
    logger.logit("Dyndns database matches local address.  No hosts update.")
    sys.exit(0)

  #
  # build the query strings
  #
  updateprefix = Dyndnsnic
  if opt_static == 1:
    updateprefix = updateprefix + "?system=statdns&hostname="
  else:
    updateprefix = updateprefix + "?system=dyndns&hostname="

  hostlist = ""
  for host in updatehosts:
    hostlist = hostlist + host + ","
    logger.logit(host + " needs updating")
  if len(hostlist) > 0:
    hostlist = hostlist[:-1]

  if opt_offline == 1:
    updatesuffix = "&myip=1.0.0.0" 
    updatesuffix = updatesuffix + "&offline=YES"
  else:
    # only do these other things if not setting offline mode
    if opt_guess == 1:
      logger.logit("Letting dyndns guess the IP.")
      updatesuffix = ""
      localip = ""
    else:
      updatesuffix = "&myip=" + localip 

    if opt_wildcard == 1:
      updatesuffix = updatesuffix + "&wildcard=ON"
    else:
      updatesuffix = updatesuffix + "&wildcard=OFF"

    if opt_backupmx == 1:
      updatesuffix = updatesuffix + "&backmx=YES"
    else:
      updatesuffix = updatesuffix + "&backmx=NO"

    if opt_mxhost != "":
      updatesuffix = updatesuffix + "&mx=" + opt_mxhost

  logger.logit("Prefix = " + updateprefix)
  logger.logit("Hosts  = " + hostlist)
  logger.logit("Suffix = " + updatesuffix)

  #
  # update those hosts 
  #
  if opt_proxy == 0:
    h2 = httplib.HTTP(Dyndnshost)
  else:
    h2 = httplib.HTTP(Dyndnshost, 8245)
  h2.putrequest("GET", updateprefix + hostlist + updatesuffix)
  h2.putheader("HOST", Dyndnshost)
  h2.putheader("USER-AGENT", Useragent)
  authstring = base64.encodestring(opt_username + ":" + opt_password)
  authstring = string.replace(authstring, "\012", "")
  h2.putheader("AUTHORIZATION", "Basic " + authstring)
  h2.endheaders()
  errcode, errmsg, headers = h2.getreply()

  # log the result
  logline = "http code = " + `errcode`
  logger.logit(logline)
  logline = "http msg  = " + errmsg
  logger.logit(logline)

  # try to get the html text
  try:
    fp = h2.getfile()
    httpdata = fp.read()
    fp.close()
  except:
    httpdata = "No output from http request."

  # create the output file
  fp = open (Htmlfile, "w")
  fp.write(httpdata)
  fp.close()
  logger.logit("ipcheck.html file created")

  #
  # check the result for fatal errors
  #
  
  # badauth may appear anywhere when errcode is 401
  if string.find(httpdata, "badauth") != -1 and errcode == 401:
    logline = "Invalid username and password specified on command line." 
    logger.logexit(logline)

    #
    # save the error to an ipcheck.err file
    #
    fp = open (Errfile, "w")
    fp.write("badauth " + opt_username + " " + opt_password + "\n")
    fp.close()
    logger.logit("ipcheck.err file created.")

    sys.exit(-1)

  # badsys must begin the resulting text and errcode is 200
  elif string.find(httpdata, "badsys") == 0 and errcode == 200:
    logline = "Bad system parameter specified (not dyndns or statdns)." 
    logger.logexit(logline)

    #
    # save the error to an ipcheck.err file
    #
    fp = open (Errfile, "w")
    if opt_static == 0:
      fp.write("badsys dyndns\n")
    else:
      fp.write("badsys statdns\n")
    fp.close()
    logger.logit("ipcheck.err file created.")

    sys.exit(-1)

  # badagent must begin the resulting text and errcode is 200
  elif string.find(httpdata, "badagent") == 0 and errcode == 200:
    logger.logexit("Badagent contact author at kal@users.sourceforge.net.")

    #
    # save the error to an ipcheck.err file
    #
    fp = open (Errfile, "w")
    fp.write("badagent\n")
    fp.close()
    logger.logit("ipcheck.err file created.")

    sys.exit(-1)

  # 911 may appear anywhere when errcode is 500
  elif string.find(httpdata, "911") != -1 and errcode == 500:
    logline = "Dyndns 911 result.  Dyndns emergency shutdown."
    logger.logexit(logline)

    #
    # save the error to an ipcheck.err file
    #
    fp = open (Errfile, "w")
    fp.write("shutdown\n")
    fp.close()
    logger.logit("ipcheck.err file created.")

    sys.exit(-1)

  # 999 may appear anywhere when errcode is 500
  elif string.find(httpdata, "999") != -1 and errcode == 500:
    logline = "Dyndns 999 result.  Dyndns emergency shutdown."
    logger.logexit(logline)

    #
    # save the error to an ipcheck.err file
    #
    fp = open (Errfile, "w")
    fp.write("shutdown\n")
    fp.close()
    logger.logit("ipcheck.err file created.")

    sys.exit(-1)

  #
  # don't really know what codes go with numhost, dnserr and wxxxx
  # probably errcode 200 but no need to assume this instead
  # assume they will be sent at the beginning of a line
  # we check those codes below
  #

  else:

    # build the results list
    results = []
    fp = open (Htmlfile, "r")
    for host in hostnames:
      resultline = fp.readline()
      if resultline[-1:] == "\n":
        resultline = resultline[:-1]
      results.append(resultline)
    fp.close()

    # check if we have one result per updatehosts 
    if len(results) == len(updatehosts):
      idx = 0
      success = 0
      for host in updatehosts:
        #
        # use logexit to generate output (email if ran from a cronjob)
        #
        if string.find(results[idx], "good") == 0:
          logline = host + " " + results[idx] + " -update successful"
          logger.logexit(logline)

          # update the localip dyndns found if guess was used
          if opt_guess == 1 and localip == "":
            p1 = string.find(results[idx], " ")
            localip = string.rstrip(results[idx][p1+1:])
            logger.logit("Dyndns guessed IP: " + localip)

          # set the success update flag
          success = 1

        elif string.find(results[idx], "nochg") == 0:
          logline = host + " " + results[idx] + " -consider abusive"
          logger.logexit(logline)

          # update the localip dyndns found if guess was used
          if opt_guess == 1 and localip == "":
            p1 = string.find(results[idx], " ")
            localip = string.rstrip(results[idx][p1+1:])
            logger.logit("Dyndns guessed IP: " + `localip`)

        elif string.find(results[idx], "abuse") == 0:
          logline = host + " " + results[idx] + " -hostname blocked for abuse"
          logger.logexit(logline)
          logger.logexit("Use the form at http://support.dyndns.org/dyndns/abuse.shtml")
          logger.logexit("Erase the ipcheck.err file when dyndns notifies you (by email).") 

          # update the localip dyndns found if guess was used
          if opt_guess == 1 and localip == "":
            p1 = string.find(results[idx], " ")
            localip = string.rstrip(results[idx][p1+1:])
            logger.logit("Dyndns guessed IP: " + `localip`)

          #
          # save the error to an ipcheck.err file
          #
          fp = open (Errfile, "a")
          fp.write("abuse " + host + "\n")
          fp.close()
          logger.logit("ipcheck.err file created.")

        elif string.find(results[idx], "notfqdn") == 0:
          logline = host + " " + results[idx] + " -FQDN hostnames needed"
          logger.logexit(logline)

          #
          # save the error to an ipcheck.err file
          #
          fp = open (Errfile, "a")
          fp.write("notfqdn " + host + "\n")
          fp.close()
          logger.logit("ipcheck.err file created.")

          # clear localip to remove ipcheck.dat file
          localip = ""

        elif string.find(results[idx], "nohost") == 0:
          logline = host + " " + results[idx] + " -hostname not found"
          logger.logexit(logline)

          #
          # save the error to an ipcheck.err file
          #
          fp = open (Errfile, "a")
          fp.write("nohost " + host + "\n")
          fp.close()
          logger.logit("ipcheck.err file created.")

          # clear localip to remove ipcheck.dat file
          localip = ""

        elif string.find(results[idx], "!yours") == 0:
          logline = host + " " + results[idx] + " -hostname not yours"
          logger.logexit(logline)

          #
          # save the error to an ipcheck.err file
          #
          fp = open (Errfile, "a")
          fp.write("!yours " + host + "\n")
          fp.close()
          logger.logit("ipcheck.err file created.")

          # clear localip to remove ipcheck.dat file
          localip = ""

        elif string.find(results[idx], "numhost") == 0:
          logline = host + " " + results[idx] + " -send ipcheck.html to support@dyndns.org"
          logger.logexit(logline)

          #
          # save the error to an ipcheck.err file
          #
          fp = open (Errfile, "a")
          fp.write("numhost " + host + "\n")
          fp.close()
          logger.logit("ipcheck.err file created.")

          # clear localip to remove ipcheck.dat file
          localip = ""

        elif string.find(results[idx], "dnserr") == 0:
          logline = host + " " + results[idx] + " -send ipcheck.html to support@dyndns.org"
          logger.logexit(logline)

          #
          # save the error to an ipcheck.err file
          #
          fp = open (Errfile, "a")
          fp.write("dnserr " + host + "\n")
          fp.close()
          logger.logit("ipcheck.err file created.")

          # clear localip to remove ipcheck.dat file
          localip = ""

        elif string.find(results[idx], "wu") == 0:
          logline = host + " " + results[idx] + " -wait until entry created"
          logger.logexit(logline)

          # get the wait code HH MM 
          try:
            codeHH = string.atoi(results[idx][2:4])
            codeMM = string.atoi(results[idx][4:6])
          except:
            codeHH = 0
            codeMM = 0
          codeHHMM = codeHH * 100 + codeMM

          # try to get the current time from the HTTP headers at dyndns 
          datetuple = headers.getdate("Date")
          if datetuple == None:
            logger.logit("Date header not found.  Using local clock.")
            datetuple = gmtime(time.time())
          currHH = datetuple[3]
          currMM = datetuple[4]
          currHHMM = currHH * 100 + currMM

          # compute the HHMM we need to wait
          if (codeHHMM <= currHHMM):
            # The codeHHMM is smaller than GMT of when we received the code.
            # Example: NIC returned 02:30 (codeHHMM) when we tried to update 
            # at 21:30 (currHHMM).  So we should be waiting 21:30 to 24:00
            # plus 00:00 to 02:30 seconds.
            waitHH = (23 - currHH) + codeHH
            waitMM = (60 - currMM) + codeMM
            logger.logit("Wraparound calculation.")
          else:
            waitHH = codeHH - currHH
            waitMM = codeMM - currMM
            logger.logit("Normal calculation.")
          
          # convert to seconds
          waitval = (waitHH * 60 + waitMM) * 60

          logger.logit("currHHMM = " + `currHHMM`)
          logger.logit("codeHHMM = " + `codeHHMM`)
          logger.logit("waitval  = " + `waitval`)

          # convert back to seconds
          #
          # save the until calculation to an ipcheck.wait file
          #
          fp = open (Waitfile, "a")
          fp.write("u " + `waitval` + "\n")
          currtime = time.time()
          fp.write(`time.time()` + "\n")
          fp.close()
          logger.logit("ipcheck.wait file created.")

          # clear localip to remove ipcheck.dat file
          localip = ""

        elif string.find(results[idx], "w") == 0:
          logline = host + " " + results[idx] + " -wait entry created"
          logger.logexit(logline)

          #
          # save the waitcode to an ipcheck.wait file
          #
          fp = open (Waitfile, "a")
          fp.write(results[idx] + "\n")
          currtime = time.time()
          fp.write(`time.time()` + "\n")
          fp.close()
          logger.logit("ipcheck.wait file created.")

          # clear localip to remove ipcheck.dat file
          localip = ""

        elif string.find(results[idx], "!donator") == 0:
          logline = host + " " + results[idx] + " -trying donator only feature"
          logger.logexit(logline)

          #
          # save the error to an ipcheck.err file
          #
          fp = open (Errfile, "a")
          fp.write("!donator " + host + "\n")
          fp.close()
          logger.logit("ipcheck.err file created.")

          # clear localip to remove ipcheck.dat file
          localip = ""

        else:
          logline = host + " " + results[idx] + " -unknown result line"
          logger.logexit(logline)

        idx = idx + 1

      if success == 1 and opt_execute != "":
        os.system (opt_execute)

    else:
      logger.logexit("Unrecognized result page in ipcheck.html.")
      
    #
    # write the update data to file
    #
    if localip != "":
      fp = open (Datfile, "w")
      if opt_offline == 0:
        fp.write(localip + "\n")
      else:
        fp.write("1.0.0.0\n")

      # hostnames == updatehosts in the current version 
      # but that may change in future versions of the client
      for host in hostnames:
        fp.write(host + "\n")
      fp.close()
      logger.logit("ipcheck.dat file created.")
    else:
      if os.path.isfile(Datfile):
        os.unlink(Datfile)
        logger.logit("ipcheck.dat file removed.")





