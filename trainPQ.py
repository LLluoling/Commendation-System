import numpy as np
import scipy.io as scio
import os
import time
import math
from scipy.sparse import coo_matrix, find,random

num_users = 19835  # 编号是0~19834
num_items = 624961  # 编号是0~624960
num_atrribute = 624952  # 编号是 9~624951
num_features = 60  #


def loadData(inputFile):
    with open(inputFile, "r", encoding="utf8") as f:
        data_list = f.readlines()
    length = len(data_list)
    i = 0
    row_user = []
    column_item = []
    score = []
    while length - i:
        item = data_list[i].split("|")
        user_id = int(item[0])
        num = int(item[1])
        row_user = row_user + [user_id] * num
        i += 1
        while num:
            record = data_list[i].split()
            column_item.append(int(record[0]))
            score.append(int(record[1])/10)
            num -= 1
            i += 1
    sparse_matrix = coo_matrix((score, (row_user, column_item)),
                               shape=(num_users, num_items),dtype='double')

    mdict = {"sparse_matrix": sparse_matrix}
    scio.savemat("sp_data.mat", mdict)
    return sparse_matrix


def InitModel(train_sparseMatrix, numberOfFeatures):
    numOfUsers, numOfItems = train_sparseMatrix.shape
    P = np.random.rand(numberOfFeatures, numOfUsers)
    Q = np.random.rand(numberOfFeatures, numOfItems)
    return P, Q

'''
def normScore(trainMatrix,flagMatrix):
    #rowValuesCount[0],rowValuesCount为list类型;数据集中每一个user都有评分，每一行都是有效的
    rowValuesCount = trainMatrix.getnnz(axis=1).tolist()
    #下面两句使得rowSum为list类型
    rowSum = trainMatrix.sum(axis=1).tolist()
    rowSum = sum(rowSum, [])
    #规范化方法
    max_matrix = np.max(trainMatrix, axis=1)
    min_matrix = np.min(trainMatrix, axis=1)
    MaxMin = max_matrix - min_matrix
    norMaxMin = []
    #下面将每一行的平均值存在row_mean中，为list类型
    row_mean = []
    for i in range(0, len(rowValuesCount)):
        row_mean.append(rowSum[i] / rowValuesCount[i])
        norMaxMin.append(np.max(MaxMin.getrow(i)))
    #至此，每一行的极差和均值以得到
    mdict = {"row_mean":row_mean,"norMaxMin":norMaxMin}
    scio.savemat("Statis.mat",mdict)

    print(time.ctime())
    print("row_mean and norMaxMin saved successfully")

    trainMatrixLil = trainMatrix.tolil()

    R_row, R_col, useless = find(flagMatrix)
    print(len(rowValuesCount))
    print(len(R_row))
    for row in range(0,len(rowValuesCount)):
        a,b,c = find(flagMatrix.getrow(row))
        for col in b:
            if trainMatrixLil[row,col]==row_mean[i] or norMaxMin[i]==0:
                trainMatrixLil[row,col] = 0
            else:
                temp = (trainMatrixLil[row,col]-row_mean[i])/norMaxMin[i]
                trainMatrixLil[row,col] =  temp
                if col==127640 and row == 0:
                    print(trainMatrix[row,col])
                    print(trainMatrixLil[row, col])
    print("test")
    print(trainMatrixLil[0, 127640])#-0.425925925926
    print("test-over")
    trainMatrix = trainMatrixLil.tocsr()

    mdict2 = {"trainMatrixNorm":trainMatrix}
    scio.savemat("normTrainMatrix.mat", mdict2)
    print(time.ctime())
    print("normTrainMatrix saved successfully")
    #exit(0)
    return trainMatrix
'''

def LearningLFM(P,Q,trainMatrix, numberOfFeatures, n, alpha, mylambda):
    # P:f*i  Q:f*u  R_:P'*Q  (i*u)
    P = P.T
    REMS_list=[]
    R_row, R_col, useless = find(trainMatrix)
    for step in range(0, n):
        eui_sum = 0
        for i in range(0, len(R_col)):
            user = R_row[i]
            item = R_col[i]
            rui = trainMatrix[user, item]
            # print("rui:"+str(rui))
            pui = Predict(user, item, P, Q, numberOfFeatures)
            eui = rui - pui
            eui_sum += eui*eui
            for f in range(0, numberOfFeatures):
                P[user, f] += alpha * (eui * Q[f, item] - mylambda * P[user, f])
                Q[f, item] += alpha * (eui * P[user, f] - mylambda * Q[f, item])
            if i % 100000 == 0:
                print(time.ctime())
                print("step:" + str(step) + " i:" + str(i))
        train_err = eui_sum / len(R_row)
        train_REMS = math.sqrt(train_err)
        print("train_REMS " + str(step) + " :" + str(train_REMS))
        REMS_list.append(train_REMS)
        alpha *= 0.9
        print(time.ctime())
        print("finish " + str(step) + " step(total:100)!")
    mdict = {"P": P, "Q": Q}
    scio.savemat("f60-10-PQ.mat", mdict)
    print(time.ctime())
    print("Save P,Q in PQ.mat successfully!")
    return  REMS_list


def Predict(user, item, P, Q,num_features):
    # P:f*u  Q:f*i  R_:P'*Q  (u*i)
   # print("user:"+str(user)+",item:"+str(item))
    value = sum(P[user, :] * Q[:, item])
    if value>10:
        value = 10
    if value<0:
        value = 0
    return value

if __name__ == "__main__":
    print(time.ctime())
    if os.path.exists("sp_data.mat"):
        mdict = scio.loadmat("sp_data.mat")
        sparse_matrix = mdict["sparse_matrix"]
    else:
        filename = 'train-rest.txt'
        sparse_matrix = loadData(filename)
    print(time.ctime())
    print("loadData successfully!")

    trainedPQ1 = "f60-10-PQ.mat"
    if(os.path.exists(trainedPQ1)):
        data = scio.loadmat(trainedPQ1)
        P = data['P']
        Q = data['Q']
        print(time.ctime())
        print("Continue training previous PQ")
    else:
        P, Q = InitModel(sparse_matrix, num_features)
        #print("initial training PQ")
        print(time.ctime())
        print("InitModel PQ successfully!")

    trainMatrix = sparse_matrix.tocsr()

    lists=LearningLFM(P,Q,trainMatrix,num_features, 10, 0.005, 0.002)
    print(lists)


