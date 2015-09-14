#!/usr/bin/env python3

# Downloads all the repos from a given Github user

import requests, json, git

baseURL  = 'https://api.github.com/users/'
reposURL = '/repos'

method = "ssh"

destDir       = './' # destination

def cloneRepo(url,destDir):
  print("Cloning "+url)
  git.repo.base.Repo.clone_from(url, destDir, recursive=True)


######## SCRIPT BEGINS HERE #########

user = input("Whose repos to clone? ")
if not user:
  print("Can't be empty")
  exit(1)


method = input("How (ssh or https)? ["+method+"] ") or method
if method != "ssh" and method != "https":
  print("Please choose a correct method.")
  exit(1)


destDir = input("Where to clone? ["+destDir+"] ") or destDir
print("Cloning "+user+"'s repos into "+destDir)

r = requests.get(baseURL+user+reposURL)
if r.status_code == 200:
  repos = r.json()
  for repo in repos:
    name = ""
    url = ""

    for attribute, value in repo.items():
      if attribute == "name":
        name = value

      elif attribute == "ssh_url" and method == "ssh":
        url = value
      elif attribute == "clone_url" and method == "https":
        url = value

      if url and name:
        try:
          cloneRepo(url,destDir+"/"+name)
        except Exception as e:
          print(e)
        finally:
          break # Next repo

else:
  print("API returned error code "+str(r.status_code)+"\nExiting...")
  exit(0)