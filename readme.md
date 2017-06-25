关于project中的程序说明（按照运行顺序）：

最主要的是excute.m文件，它调用别的函数(除了.py文件)去完成几乎整个训练和验证以及测试过程

调用函数以及顺序如下：

1、separate_file_new.py 将train.txt分为训练集和验证集

2、FormMatrix.m 读入分好的训练集到稀疏矩阵中

3、trainPQ.py 利用LFM算法训练P,Q矩阵（matlab代码实现LFM算法的是CostFunc.m和fmincg.m函数）

4、checkValid.py 通过验证集的RMSE选择最好的P,Q矩阵

5、attributeGet.m获得attributeItem.txt中的属性值与电影的关系

6、GetUser_attr.m 利用content-based方法训练用户对属性的评分情况

7、validation.m 是通过训练集去选择最合适的参数值alpha去结合LFM算法和content-based算法

8、test.m 根据之前训练的模型结果输出测试集预测评分


