import re

print("ass")
train_part = ""
valid_part = ""
pattern = re.compile('[\d]+|[\d]+')
count = 0
with open("train.txt", "r", encoding="utf8") as f1:
    # with open("train.txt","r",encoding="utf8") as f1:
    line = f1.readline()
    count += 1
    while line:
        if re.match(pattern, line) is not None:

            #print(line)
            id = line.split("|")[0]
            num = line.split("|")[1]

            # valid_num = int(int(num) * 0.3)
            if (int(num) > 6):
                valid_num = 6
            else:
                valid_num = num
            train_num = int(num) - valid_num
            valid_part = valid_part + id + "|" + str(valid_num) + "\n"
            train_part = train_part + id + "|" + str(train_num) + "\n"
            while valid_num > 0:
                line = f1.readline()
                count += 1
                if count % 10000 == 0:
                    print(str(count) + " finished")
                valid_part = valid_part + line
                valid_num -= 1
            while train_num > 0:
                line = f1.readline()
                count += 1
                if count % 10000 == 0:
                    print(str(count) + " finished")
                train_part = train_part + line
                train_num -= 1
        line = f1.readline()
        count += 1
        if count % 10000 == 0:
            print(str(count) + " finished")

with open("txt_valid-rest.txt", "w", encoding="utf8") as f2:
    f2.write(train_part)

with open("txt_valid-6.txt", "w", encoding="utf8") as f3:
    f3.write(valid_part)

'''

with open("txt_train.txt","w",encoding="utf8") as f2:
    f2.write(train_part)

with open("txt_valid.txt","w",encoding="utf8") as f3:
    f3.write(valid_part)
'''





