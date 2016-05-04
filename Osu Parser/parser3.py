beatmap = open('map.osu', 'r')  # change map.osu to file name

readBeatmap = beatmap.read()

beatmaplist = readBeatmap.split('\n\n')  # split by empty lines

print ("Parsing...")

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

# remove comments in events
cleanevents = [e for e in events if not "//" in e]

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

    hitobjectsconverted.append(str(int(notex)) + ',' + str(int(time)) + ',' + str(int(noteType)))

print ("Writing...")

# start writing to file
output = open('map.bMap', 'w')

# write metadata
output.write("[Metadata]\n")
for writebuffer in range(0, len(general)):
    output.write(general[writebuffer] + "\n")
for writebuffer in range(0, len(editor)):
    output.write(editor[writebuffer] + "\n")
for writebuffer in range(0, len(metadata)):
    output.write(metadata[writebuffer] + "\n")
for writebuffer in range(0, len(cleanevents)):
    output.write(cleanevents[writebuffer] + "\n")

# write hitobjects
output.write("\n[Hitobjects]\n")
for writebuffer in range(0, len(hitobjectsconverted)):
    output.write(hitobjectsconverted[writebuffer] + "\n")
output.close()
