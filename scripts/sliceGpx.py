import os
import re
import datetime
import sys
import xml.etree.ElementTree as xee

# Usage: python3 /path/to/sliceGpx.py input.gpx 20230101_235900_123.mp4 >! out.gpx

local_tz = datetime.datetime.now().astimezone().tzinfo

gpx_filename = sys.argv[1]
video_filename = sys.argv[2]

date_matched = re.match('.*(20\d\d)(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})_(\d{3}).*', video_filename)
date_matched = datetime.datetime(*map(int, list(date_matched.group(1,2,3,4,5,6))), int(date_matched.group(7)) * 1000, local_tz)

timedelta = -(date_matched.astimezone().utcoffset())
start_datetime = date_matched + timedelta

video_duration = os.popen(f'ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 {video_filename}').read()
video_duration = re.match('(\d+)\.(\d+)', video_duration)
video_duration_seconds, video_duration_microseconds = video_duration.group(1,2)

end_datetime = start_datetime + datetime.timedelta(seconds=int(video_duration_seconds), microseconds=int(video_duration_microseconds))

ns = { 'gpx': 'http://www.topografix.com/GPX/1/1' }
xee.register_namespace('', "http://www.topografix.com/GPX/1/1")
xee.register_namespace('gpxtpx', "http://www.garmin.com/xmlschemas/TrackPointExtension/v1")
xee.register_namespace('gpxx', "http://www.garmin.com/xmlschemas/GpxExtensions/v3")
gpx_content = open(gpx_filename, "r").read()
gpx_xml = xee.fromstring(gpx_content)
trkseg = gpx_xml.find('gpx:trk/gpx:trkseg', ns)

print('Start and end datetimes:', (start_datetime.isoformat(sep='T', timespec='auto'), end_datetime.isoformat(sep='T', timespec='auto')), file=sys.stderr)

for trkpt in trkseg.findall('./gpx:trkpt', ns):
    point_date = trkpt.find('./gpx:time', ns).text
    point_datetime = datetime.datetime.strptime(point_date, '%Y-%m-%dT%H:%M:%S%z')
    if point_datetime < start_datetime or point_datetime > end_datetime:
        #print(f'Removing {point_datetime}', file=sys.stderr)
        trkseg.remove(trkpt)

print(xee.tostring(gpx_xml, encoding='unicode', xml_declaration=True))
