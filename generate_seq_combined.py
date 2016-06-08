import psycopg2
import math
import datetime
import random
import json

uniq_p_feat = ["gender", "age", "white", "asian", "hispanic", "black", "multi", "portuguese",
               "american", "mideast", "hawaiian", "other"]


def set_p_features(hadm_id):
    cur.execute("""SELECT dob, admittime, gender, ethnicity from admissions join patients
                on admissions.subject_id = patients.subject_id
                where hadm_id = %(hadm_id)s """ % {'hadm_id': str(hadm_id)})
    subject_info = cur.fetchall()
    feats = {}
    for k in uniq_p_feat:
        feats[k] = 0

    feats["gender"] = int(subject_info[0][2] == "M")
    num_years = (subject_info[0][1] - subject_info[0][0]).days / 365.25
    feats["age"] = num_years

    r = subject_info[0][3]
    if "WHITE" in r:
        feats["white"] = 1
    elif "ASIAN" in r:
        feats["asian"] = 1
    elif "HISPANIC" in r:
        feats["hispanic"] = 1
    elif "BLACK" in r:
        feats["black"] = 1
    elif "MULTI" in r:
        feats["multi"] = 1
    elif "PORTUGUESE" in r:
        feats["portuguese"] = 1
    elif "AMERICAN INDIAN" in r:
        feats["american"] = 1
    elif "MIDDLE EASTERN" in r:
        feats["mideast"] = 1
    elif "HAWAIIAN" in r or "CARIBBEAN" in r:
        feats["hawaiian"] = 1
    else:
        feats["other"] = 1
    return feats


def get_patient_history(tuple_his):
    res = {}
    res['interval'] = tuple_his[1]
    res['readmission'] = tuple_his[2]
    res['disease'] = tuple_his[3]
    res['d_interval'] = tuple_his[4]
    res['death'] = tuple_his[5]
    return res


print("Start")
try:
        conn = psycopg2.connect("dbname='mimic' user='mimic' host='localhost' password='mimic'")
except:
        print("I am unable to connect to the database")

cur = conn.cursor()
cur.execute("""set search_path to mimiciii""")
cur.execute("""SELECT subject_id, charttime, event_type, event, icd9_3, hadm_id
            from allevents order by subject_id, charttime, event_type desc, event""")
rows = cur.fetchall()
print("Query executed")

query_get_sublist = """select subject_id, interval, readmission, disease, d_interval, death from sublist"""
cur.execute(query_get_sublist)

#qualified_patients = list(map(lambda x: x[0], cur.fetchall()))
qualified_patients = cur.fetchall()
print ("cnt of patients: {}".format(len(qualified_patients)))
print (qualified_patients[0])
print (type (qualified_patients[0]))

all_history = {}
for one in qualified_patients:
    all_history[one[0]] = get_patient_history(one)

prev_time = None
prev_subject = None
prev_hadm_id = None
diags = set()
total_diags = set()
event_seq = []
temp_event_seq = []
all_seq = []

qualified_cnt = 0


##Change this target disease ID to generate different datasets
d_target = "d_272"
d_label = 0
discard = False

print("length of rows: {}".format(len(rows)))

for row in rows:
    ##if row[0] not in all_history:
    ##    continue

    qualified_cnt += 1

    if row[2] == "diagnosis":
        event = row[2][:1] + "_" + row[4]
    else:
        event = row[2][:1] + "_" + row[3]

    if row[0] is None or row[1] is None or row[5] is None:
        continue

    elif prev_time is None or prev_subject is None:
        pass
    elif row[0] == prev_subject and discard:
        continue
    elif (row[0] != prev_subject):# or (row[1] > prev_time + datetime.timedelta(365)):
        #if len(diags) > 0 and len(event_seq) > 4:
        p_features = set_p_features(row[5])
        ##p_history = all_history[row[0]]
        all_seq.append([row[0], p_features, event_seq, temp_event_seq, diags, d_label])

        diags = set()
        event_seq = []
        temp_event_seq = []
        discard = False
        d_label = 0

    elif prev_hadm_id != row[5]:
        event_seq += temp_event_seq
        temp_event_seq = []
        diags = set()



    temp_event_seq.append(event)

    prev_time = row[1]
    prev_subject = row[0]
    prev_hadm_id = row[5]

    if row[2] == "diagnosis":
        if event == d_target:
            discard = True
            d_label = 1
        diags.add(event)
        total_diags.add(event)

print("Number of total sequences {}".format(len(all_seq)))
print("Data structures created. Now writing files:")
train = {}
test = {}

# To include all diagnoses change it to total_diags
#for i in range(10):
#    train[str(i)] = open('../Data/seq_combined/mimic_train_'+str(i), 'w')
#    test[str(i)] = open('../Data/seq_combined/mimic_test_'+str(i), 'w')


segment = 0
random.shuffle(all_seq)
total = len(all_seq)

fout = open('first_incident_disease', 'w')
cnts = [0, 0]
len_seq = 0

for seq_index, seq in enumerate(all_seq):

    [pid, patient, events, final_events, diagnoses, d_label] = seq
    serial = str(pid)
    serial += "|" + (",").join(diagnoses)
    serial += "|" + json.dumps(patient)
    serial += "|" + " ".join(events)
    serial += "|" + " ".join(final_events)
    serial += "|" + str(d_label)

    cnts[d_label] += 1
    len_seq += len(events) + len(final_events)
    ##serial += "|" + json.dumps(history)

    fout.write(serial+'\n')

#for i in range(10):
#    train[str(i)].close()
#    test[str(i)].close()
print ("sanity check")
print ("cnt of 0: {}".format(cnts[0]))
print ("cnt of 1: {}".format(cnts[1]))
print ("average length of seq: {}".format(len_seq / len(all_seq)))


print("Done")
fout.close()