import psycopg2
import math
import datetime
import random
import json


uniq_p_feat = ["gender", "age", "white", "asian", "hispanic", "black", "multi", "portuguese",
               "american", "mideast", "hawaiian", "other"]

def parseLine(line):
    global patients
    global allEvents
    global labels
    global feats
    [pid, diagnoses, demo, events_str, final_events_str, d_label] = line.split("|")
    #print(len(meow))
    events = events_str.strip().split() + final_events_str.strip().split()
    #print (len(final_events_str.strip().split()))
    patients[pid] = events
    coded_feat = []
    #print(demo)
    j_patient = json.loads(demo)
    for feat in uniq_p_feat:
        coded_feat.append(j_patient[feat])
    feats[pid] = coded_feat
    allEvents = allEvents.union(events)
    labels[pid] = d_label

lambda_decay = 0.01

def decay(t):
    return math.exp(- lambda_decay * t)

global patients
patients = {}
global allEvents
allEvents = set()
global labels
labels = {}
global feats
feats = {}
res = {}

fin = open("first_incident_disease", "r")

for line in fin:
    parseLine(line)

fin.close()

print(len(patients))
print(len(allEvents))


sortedEvents = sorted(list(allEvents))

eventIndex = {}

for e in sortedEvents:
    eventIndex[e] = len(eventIndex)

print(len(eventIndex))
cnt_events = len(eventIndex)
labelIndex = {}
labelIndex["alive"] = 0
labelIndex["dead"] = 1
labelIndex["yes"] = 1
labelIndex["no"] = 0


for p in patients:
    temp = [0] * cnt_events
    seq = patients[p]
    l = len(seq)
    for i, e in enumerate(seq):
        temp[eventIndex[e]] = decay(l-1 - i)

    #history = json.loads(labels[p])
    temp = [labels[p]] + feats[p] + temp
    res[p] = temp

print(len(res))
print(len(uniq_p_feat))
print(len(list(res.values())[0]))

fout = open('matrix.csv', 'w')
for p in res.keys():
    line = res[p]
    fout.write(p + ',' + ','.join(map(str, line)) + '\n')
fout.close()
