#!/usr/bin/env python

import requests, json, urllib, time, subprocess, shutil, os

baseURL               = 'https://api.t411.me/'
authURL               = baseURL+'auth'
todayURL              = baseURL+'torrents/top/today'
downloadURL           = baseURL+'torrents/download/'

t411username          = ''
t411password          = ''
transmissionUsername  = ''
transmissionPassword  = ''

# Requirements for new torrents
nbSeedersMin          = 1
nbSeedersMax          = 3
nbLeechersMin         = 60

torrentsDestDir       = '/tmp' # *.torrent destination

timeAboveOne          = 7200 # Two hours, time before torrents (ratio >= 1) are deleted
timeBelowOne          = 259200 # Three days, time before torrents (ratio < 1) are deleted

def downloadTorrent(url, id, httpHeaders, destDir):
  r = requests.get(url, headers=httpHeaders)
  with open(destDir+"/%s.torrent"%id, 'wb') as fd:
    for chunk in r.iter_content(4096):
      fd.write(chunk)

def getDiskSpaceLeft():
  """Took from https://gist.github.com/xamox/4711286"""
  st = os.statvfs("/")
  free = (st.f_bavail * st.f_frsize)
  return free

######## SCRIPT BEGINS HERE #########

present = time.localtime()
print("##################################\n"+time.asctime(present)+"\n##################################")

currentTorrents = subprocess.check_output(["transmission-remote", "-n", transmissionUsername+":"+transmissionPassword, "-l"])

lines = [line.split() for line in currentTorrents.splitlines(False)]
lines.pop() # Remove last line
del lines[0] # Remove first line

for torrent in lines:
  uid = torrent[0].decode("utf-8").replace('*','').strip()
  done = torrent[1].decode("utf-8").replace('%','').strip()
  ratio = torrent[7].decode("utf-8").strip()

  output = subprocess.check_output(["transmission-remote", "-n", transmissionUsername+":"+transmissionPassword, "-t", uid, "-i"])

  for item in output.splitlines(False):
    newitem = item.decode('utf-8').strip()
    if 'Name:' in newitem:
      name = newitem
      if float(done) == 0:
        subprocess.call(["transmission-remote", "-n", transmissionUsername+":"+transmissionPassword, "-t", uid, "--remove-and-delete"])
        print("[DELETED] "+name)
        print("Ratio: 0")
        time.sleep(1)
        break

    if 'Latest activity' in newitem:
      liste = newitem.split(':',1) # Split only one time
      timestamp = time.strptime(liste[1].strip())
      difference = time.mktime(present)-time.mktime(timestamp)
      if ((float(ratio) >= 1 and difference > timeAboveOne) or (float(ratio) < 1 and difference > timeBelowOne)):
        subprocess.call(["transmission-remote", "-n", transmissionUsername+":"+transmissionPassword, "-t", uid, "--remove-and-delete"])
        print("[DELETED] "+name)
        print("Ratio: "+ratio+"\nLast activity: "+str(difference)+" seconds ago")
        time.sleep(1)
        break

freeSpace = getDiskSpaceLeft()
print("Free space: "+str(freeSpace)+" bytes")
credentials = {'username': t411username, 'password': t411password}

auth = requests.post(authURL, data=credentials)
token = auth.json()['token']
headers = {'Authorization': token}

search = requests.get(todayURL, headers=headers)
torrents = json.loads(search.text)

totalSize = 0
for el in torrents:
  if (int(el['leechers']) >= nbLeechersMin) and (int(el['seeders']) >= nbSeedersMin) and (int(el['seeders']) <= nbSeedersMax):
    downloadTorrent(downloadURL+'%s'%el['id'], el['id'], headers, torrentsDestDir)
    totalSize += int(el['size'])
    if freeSpace - totalSize >= 100000000: # More than 100MB free space
      with open(os.devnull, "w") as f:
        ret = subprocess.call(["transmission-remote", "-n", transmissionUsername+":"+transmissionPassword, "-a", "%s/%s.torrent"%(torrentsDestDir,el['id'])],stdout=f)
        if ret==0:
          print("[ADDED] "+el['name'])
          print("Seeders: "+el['seeders']+"\tLeechers: "+el['leechers']+"\tSize: "+el['size']+" bytes")
        else:
          print("[NOT ADDED - DUPLICATE] "+el['name'])
    else:
      totalSize -= int(el['size'])
      print("[NOT ADDED - NOT ENOUGH SPACE] "+el['name'])
