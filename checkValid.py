import scipy.io as scio
from numpy import *
import numpy as np
from scipy.sparse import coo_matrix, find
import time
import os

num_users=19835         #编号是0~19834
num_items=624961      #编号是0~624960


def Predict(user,item,P,Q):
    # P:f*i  Q:f*u  R_:P'*Q  (i*u)
    # P:f*u  Q:f*i  R_:P'*Q  (u*i)
    # print("user:"+str(user)+",item:"+str(item))
    value = sum(P[user, :] * Q[:, item])
    if value > 10:
        value = 10
    if value < 0:
        value = 0
    return value

def loadData(inputFile):
    with open(inputFile,"r",encoding="utf8") as f:
        data_list = f.readlines()
    length = len(data_list)
    i=0
    row_user = []
    column_item = []
    score = []
    while length-i :
        item = data_list[i].split("|")
        user_id = int(item[0])
        num = int(item[1])
        row_user = row_user + [user_id] * num
        i += 1
        while num:
            record = data_list[i].split()
            column_item.append(int(record[0]))
            score.append(int(record[1]))
            num -= 1
            i += 1
    valid_sparse_matrix = coo_matrix((score, (row_user, column_item)),
                                     shape=(num_users, num_items))
    R_score = [1] * len(score)
    valid_R_sparse_matrix = coo_matrix((R_score, (row_user, column_item)),
                                       shape=(num_users, num_items))
    mdict = {"valid_sparse_matrix": valid_sparse_matrix, "valid_R_sparse_matrix": valid_R_sparse_matrix}
    scio.savemat("valid_data.mat", mdict)
    return valid_sparse_matrix, valid_R_sparse_matrix


def loadPQMat(PQMatFile):
    if (os.path.exists(PQMatFile)):
        data = scio.loadmat(PQMatFile)
        trained_P = data['P']
        trained_Q = data['Q']
    else:
        print("load PQ failed!")

    print(time.ctime())
    print("load PQ successfully!")
    return trained_P, trained_Q


def loadValidMatrix(validDataFile,inputFile):
    if (os.path.exists(validDataFile)):
        data = scio.loadmat(validDataFile)
        valid_sparse_matrix = data['valid_sparse_matrix']
        Valid_R_sparse_matrix = data['Valid_R_sparse_matrix']
        print(time.ctime())
        print("load valid_data.mat successfully!")
    else:
        valid_sparse_matrix, Valid_R_sparse_matrix = loadData(inputFile)
        print(time.ctime())
        print("load inputFile successfully!")
    return valid_sparse_matrix, Valid_R_sparse_matrix


def checkValid(PQMatFile,validDataFile,inputFile,output_result):
    #P:user*feature,Q:feature*item
    trained_P,trained_Q = loadPQMat(PQMatFile)
    valid_sparse_matrix,Valid_R_sparse_matrix = loadValidMatrix(validDataFile,inputFile)
    valid_trainMatrix = valid_sparse_matrix.tocsr()
    valid_flagMatrix = Valid_R_sparse_matrix.tocsr()


    R_row, R_col, useless = find(valid_flagMatrix)
    output_tuple = []
    print(len(R_row))
    eui_square_sum = 0
    for i in range(0,len(R_row)):
        user = R_row[i]
        item = R_col[i]
        rui = valid_trainMatrix[user, item]
        pui  = Predict(user,item,trained_P,trained_Q)
        if pui<0:
            pui = 0
        if pui>10:
            pui = 10
        pui = pui*10
        eui = rui-pui
        eui_square_sum += eui*eui
        tuple = (user,item,rui,pui,eui)
        output_tuple.append(tuple)
        RMSE = math.sqrt(eui_square_sum/len(R_row))
        print("RMSE:"+str(RMSE))

    print(time.ctime())
    print("output_tuple.mat save successfully,Now begin write file")
    with open(output_result, "w") as f:
        for i in range(0, len(output_tuple)):
            #f.write("%-8d%-10d%-8d%-8d%-8.2f" % (output_tuple[i,0],output_tuple[i,1],output_tuple[i,2],
            #                                     output_tuple[i, 3],output_tuple[i,4]))
            f.write("%-8d%-10d%-8d%-8d%-8.2f" % (output_tuple[i]))
            f.write("\n")

inputFile = "txt_valid-6.txt"
PQMatFile = "f60-30-PQ.mat"
validDataFile = "valid_data.mat"


output_result = "valid_result(f60-30).txt"

checkValid(PQMatFile,validDataFile,inputFile,output_result)
print(time.ctime())
print("Now  write file finished")

#print(math.sqrt(4098.422))