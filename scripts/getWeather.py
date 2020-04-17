#!/usr/bin/env python3

import urllib.request, json

city = "Berlin"
api_key = "16f57223a1d6ab7a0cb25f9cbdcd8d56"
units = "Metric"
unit_key = "C"

weather = eval(str(urllib.request.urlopen("http://api.openweathermap.org/data/2.5/weather?q={}&APPID={}&units={}".format(city, api_key, units)).read())[2:-1])

info = weather["weather"][0]["description"].capitalize()
temp = str(weather["main"]["temp"])

print("%s, %s °%s" % (info, temp, unit_key))

