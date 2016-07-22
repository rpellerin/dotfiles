from bs4 import BeautifulSoup
import urllib.request
import re

base_url = "http://69.89.31.234/~euroleat/admin/"

c = urllib.request.urlopen(base_url+"database.php")
content = c.read()

urls = []

import urllib.request
import sys
def prr(array):
    str = ""
    for item in array:
        str += item+','

    return str[:-1]

def parse(url):
    with urllib.request.urlopen(base_url+url) as response:
        # print("Parsing..."+url)
        html = response.read()
        try:
            html = html.decode(response.headers.get_content_charset())
        except:
            html = html.decode('ISO-8859-1')
        # name city country products employees turnover comments
        name_r = re.search(r'Name:<\/b>(.*?)<\/td>', html, re.S)
        name = name_r.group(1).strip()

        country_r = re.search(r'<b>Country:<\/b>(.*?)<\/td>', html, re.S)
        country = country_r.group(1).strip()

        city_r = re.search(r'<b>City:</b>(.*?)</td></tr>', html, re.S)
        city = city_r.group(1).strip()

        prod_r = re.findall(r'<li>(.*?)<\/li>(?=.*Raw)', html, re.S)
        products = prod_r

        empl_r = re.search(r'Employees.*?<td colspan="4">(.*?)<\/td>', html, re.S)
        empl = empl_r.group(1).strip()

        turn_r = re.search(r'Turnover.*?<td colspan="4">(.*?)<\/td>', html, re.S)
        turn = turn_r.group(1).strip()

        comm_r = re.search(r'Comments.*?<td colspan="4">(.*?)<\/td>', html, re.S)
        comm = comm_r.group(1).replace("\n"," ").replace("\r", "").strip()

        return base_url+url+";"+name+";"+country+";"+city+";"+empl+";"+turn+";"+comm+";"+prr(products)

with urllib.request.urlopen(base_url+'database.php') as response:
    html = response.read().decode(response.headers.get_content_charset())
    html = str(html)

    counter = 0
    for m in re.finditer(r"database1\.php\?id=(\d+)", html):
        urls.append(m.group(0))
        counter += 1

    print("URL;Name;Country;City;Employees;Turnover;Comments;Products")
    final = []
    count = 1
    for url in urls:
        print(str(count), file=sys.stderr)
        count += 1
        print(parse(url))
