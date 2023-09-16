import os
import re
import datetime
import sys

# Usage: python3 /path/to/updateTimeInsta360File.py 20230101_235900_123.mp4

local_tz = datetime.datetime.now().astimezone().tzinfo

video_filename = sys.argv[1]
date_matched = re.match('.*(20\d\d)(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})_(\d{3}).*', video_filename)
date_matched = datetime.datetime(*map(int, list(date_matched.group(1,2,3,4,5,6))), int(date_matched.group(7)) * 1000, local_tz)

timedelta = -(date_matched.astimezone().utcoffset())
correct_date = date_matched + timedelta

# Update mtime
os.utime(video_filename, (correct_date.timestamp(), correct_date.timestamp()))
print(f'New mtime changed to {correct_date}')

# Update mtime in video metadata through ffmpeg
iso = correct_date.isoformat(sep='T', timespec='auto')
print(f'If you intend to post this on Youtube as a Short, you should now run: ffmpeg -i {video_filename} -metadata creation_time={iso} -c:v copy -c:a copy output.mp4')
