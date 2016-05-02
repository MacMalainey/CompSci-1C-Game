import json
import math

beatmap = open('map.osu', 'r')

readBeatmap = beatmap.read()

beatmaplist = readBeatmap.split('\n\n') # split by empty lines

print "Parsing..."

# find each section, split into individual lists
general = [a for a in beatmaplist if "[General]" in a][0].splitlines()
editor = [a for a in beatmaplist if "[Editor]" in a][0].splitlines()
metadata = [a for a in beatmaplist if "[Metadata]" in a][0].splitlines()
difficulty = [a for a in beatmaplist if "[Difficulty]" in a][0].splitlines()
events = [a for a in beatmaplist if "[Events]" in a][0].splitlines()
timingpoints = [a for a in beatmaplist if "[TimingPoints]" in a][0].splitlines()
hitobjects = [a for a in beatmaplist if "[HitObjects]" in a][0].splitlines()

# remove unnecessary tags
general.remove("[General]")
editor.remove("[Editor]")
metadata.remove("[Metadata]")
difficulty.remove("[Difficulty]")
events.remove("[Events]")
timingpoints.remove("[TimingPoints]")
hitobjects.remove("[HitObjects]")

# remove empty entries
if '' in general: general.remove('')
if '' in editor: editor.remove('')
if '' in metadata: metadata.remove('')
if '' in difficulty: difficulty.remove('')
if '' in events: events.remove('')
if '' in timingpoints: timingpoints.remove('')
if '' in hitobjects: hitobjects.remove('')

# start converting hitobjects
hitobjectsconverted = []

for notenum in range(0, len(hitobjects)):
    convertbuffer = hitobjects[notenum].split(",")
    notex = int(convertbuffer[0])/(512/4)
    # y is ignored in favor of time
    time = int(convertbuffer[2])
    # check if note is held note
    if int(convertbuffer[3]) == 128:
        noteType = convertbuffer[5].split(":")[0]
    else:
        noteType = -1

    hitobjectsconverted.append(str(notex) + ',' + str(time) + ',' + str(noteType))

print "Writing..."

# start writing to file
output = open('output.txt', 'w')
output.write(json.dumps(hitobjectsconverted, sort_keys=True, indent=4))
output.close()