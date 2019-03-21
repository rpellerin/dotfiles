#!/usr/bin/env python3

import urllib.request, json, time

air_quality_ile_de_france_url = "https://services8.arcgis.com/gtmasQsdfwbDAQSQ/arcgis/rest/services/ind_idf_agglo/FeatureServer/0/query?where=1%3D1&outFields=*&returnGeometry=false&orderByFields=date_echea%20DESC&outSR=4326&f=json"
air_quality = json.loads(eval(str(urllib.request.urlopen(air_quality_ile_de_france_url).read())))

quality = air_quality["features"][0]["attributes"]["qualificat"].capitalize()
quality_value = int(air_quality["features"][0]["attributes"]["valeur"])
measure_date = int(str(air_quality["features"][0]["attributes"]["date_echea"])[0:-3])
measure_date =  time.strftime("%a, %d %b %Y %H:%M:%S", time.localtime(measure_date))

pm25_url = "https://services8.arcgis.com/gtmasQsdfwbDAQSQ/arcgis/rest/services/mes_idf_horaire_pm25/FeatureServer/0/query?where=UPPER(code_station_ue)%20like%20%27%254143%25%27&outFields=*&returnGeometry=false&orderByFields=date_fin%20DESC&outSR=4326&f=json"
pm25_levels = json.loads(eval(str(urllib.request.urlopen(pm25_url).read())))

pm25_value = "%.1f" % (float(pm25_levels["features"][0]["attributes"]["valeur"]))
pm25_unit = str(pm25_levels["features"][0]["attributes"]["unite"])
pm25_measure_date = int(str(pm25_levels["features"][0]["attributes"]["date_fin"])[0:-3])
pm25_measure_date =  time.strftime("%a, %d %b %Y %H:%M:%S", time.localtime(pm25_measure_date))

pm10_url = "https://services8.arcgis.com/gtmasQsdfwbDAQSQ/arcgis/rest/services/mes_idf_horaire_pm10/FeatureServer/0/query?where=UPPER(code_station_ue)%20like%20%27%254143%25%27&outFields=*&returnGeometry=false&orderByFields=date_fin%20DESC&outSR=4326&f=json"
pm10_levels = json.loads(eval(str(urllib.request.urlopen(pm10_url).read())))

pm10_value = "%.1f" % (float(pm10_levels["features"][0]["attributes"]["valeur"]))
pm10_unit = str(pm10_levels["features"][0]["attributes"]["unite"])
pm10_measure_date = int(str(pm10_levels["features"][0]["attributes"]["date_fin"])[0:-3])
pm10_measure_date =  time.strftime("%a, %d %b %Y %H:%M:%S", time.localtime(pm10_measure_date))


print("%s, %i/10 | PM2.5: %s/%s (max 25) | PM10: %s/%s (max 50)" % (quality, quality_value, pm25_value, pm25_unit, pm10_value, pm10_unit))

