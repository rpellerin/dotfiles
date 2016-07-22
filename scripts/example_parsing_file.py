import sys, re

if len(sys.argv) < 2:
    sys.stderr.write("Please give the file to parse as the unique argument.\n")
    sys.exit(1)

filename = sys.argv[1]

# Variables
diff_arrived_displayed = []
cpu = []
fps = []

file=open(filename, 'r')
rows = file.readlines()

for line in rows:
    if line.find("TimeStampFrequency") > -1:
        m = re.search(r'TimeStampFrequency is (\d+)', line)
        timestamp_freq = m.group(1)

    arrived = re.search(r'arrived at (\d+)', line)
    if arrived: latest_arrived = arrived.group(1)

    displayed = re.search(r'Displayed packet .*? at (\d+)', line)
    if displayed: diff_arrived_displayed.append(int(displayed.group(1)) - int(latest_arrived))

    cpu_fps = re.search(r'CPU=(\d+)%, FPS=(\d+)', line)
    if cpu_fps:
        cpu.append(int(cpu_fps.group(1)))
        fps.append(int(cpu_fps.group(2)))

print "Timestamp frequency is", timestamp_freq

print "Max difference between arrived and diplayed is\t\t", max(diff_arrived_displayed)
print "Min difference between arrived and diplayed is\t\t", min(diff_arrived_displayed)
print "Average difference between arrived and displayed is\t", reduce(lambda x, y: x + y, diff_arrived_displayed) / len(diff_arrived_displayed)
print "Average CPU is\t", reduce(lambda x, y: x + y, cpu) / len(cpu)
print "Average FPS is\t", reduce(lambda x, y: x + y, fps) / len(fps)
print "Average difference between arrived and displayed is\t", sum(diff_arrived_displayed) / len(diff_arrived_displayed)
print "Average CPU is\t", sum(cpu) / len(cpu)
print "Average FPS is\t", sum(fps) / len(fps)
