%load data
%------------------说明----------------------------------------------------
%通过一段小程序(见注释中的.py程序)，先对train.txt以及itemAttribute.txt进行检验，
%发现用户的个数有19835个；电影的个数有1624961；属性的个数有71878个，范围在9~624951
%用FormMatrix这个函数去建立一个稀疏矩阵，读取所有的评分
%  Y is a 1624961x19835 sparse matrix, containing ratings (0-100) of 1624961 
%  movies on 19835 users
%  R is a 1624961x19835 sparse matrix, where R(i,j) = 1 if and only if user 
% j gave a rating to movie i
%--------------------------------------------------------------------------
num_users=19835; %编号是0~19834
num_movies=624961;%编号是0~624960
num_atrribute=624952;%编号是 9~624951
filename='txt_train.txt';
[Y , R] = FormMatrix(filename,num_movies,num_users);
%pause;
fprintf('Y R finished');
save YR.mat Y  num_users num_movies


%normalize data
%------------------说明----------------------------------------------------
%通过一段小程序，对系数矩阵进行归一化，使得每个电影的平均分为0，数据呈现出均匀分布的状态
%但是在最终的结果中我们没有使用Ynorm,所以我们注释了该段代码
%normalize Y
%--------------------------------------------------------------------------
% Ymean = zeros(num_movies, 1);
% Ynorm = sparse(num_movies,num_users);
% for i = 1:num_movies
%     fprintf('%d \r\n',i);
%     idx = find(R(i, :) == 1);
%     if(isempty(idx)~=1)
%         Ymean(i) = mean(Y(i, idx));
%         Ynorm(i, idx) = Y(i, idx) - Ymean(i);
%     end
% end
% pause;
%其中我存储了目前所有的值于'NormalizeData.mat'
%save NormalizeData.mat Ymean Ynorm num_users num_movies num_atrribute
% load('NormalizeData.mat');


%奇异值分解
%------------------说明----------------------------------------------------
%这部分是LFM的模型训练，使用随机梯度下降，通过训练集找到最优的奇异值分解结果，找
%到最好的P,Q矩阵。由于matlab太慢，这部分一用相同原理的python代码代替，这里为了之
%后的运行，只需要load最终由python代码训练出来的PQ。
%--------------------------------------------------------------------------
load 'f20-100-PQ.mat'
%{
num_features=20; 
Q = randn(num_movies, num_features); 
P =randn(num_users, num_features); 
initial_parameters = [Q(:); P(:)];
options = optimset('GradObj', 'on', 'MaxIter', 50); 
lambda1=10;
lambda2=10; 
[theta,cost] = fmincg (@(t)(CostFunc(t, Ynorm, R, num_users,num_movies, ...
          num_features, lambda1, lambda2)),initial_parameters, options);
Unfold the returned theta back into P and Q 
Q =reshape(theta(1:num_movies*num_features), num_movies, num_features); 
P =reshape(theta(num_movies*num_features+1:end), num_users, num_features);   
save QP2.mat Q P
%}

%引入属性值的作用
%------------------说明----------------------------------------------------
%这里引入一个稀疏矩阵存储movie与属性之间的关系
%Attr是一个num_movies*num_atrattribute的关系矩阵
%user_mean是一个用户打平均分的矩阵
%User_attr是一个稀疏矩阵，表示每个用户向属性打的平均分
%--------------------------------------------------------------------------
Attr=attributeGet('itemAttribute.txt',num_movies);
user_mean=zeros(num_users,1);
for i=1:num_users
    idx=find(R(:,i)==1);
    user_mean(i)=sum(Y(idx,i))/length(idx);
end
[User_attr]=GetUser_attr(Y,R,num_atrribute,Attr);
% 其中我存储了目s前所有的值于'Attribute.mat'
save Attr.mat Attr User_attr user_mean
load('Attribute.mat');

%validation
%------------------说明----------------------------------------------------
%使用validation的测试集
%--------------------------------------------------------------------------
Y_vali=zeros(num_users,6);
movie_vali=zeros(num_users,6);
f=fopen('txt_valid-6.txt','rt');
tic
while feof(f)==0
    line=fgetl(f);
    temp=regexp(line,'\|','split');
    t_user=str2double(cell2mat(temp(1)))+1;
    for i=1:6
        line=fgetl(f);
        tmp=regexp(line,'\s+','split');
        movie_vali(t_user,i)=str2double(cell2mat(tmp(1)))+1;
        Y_vali(t_user,i)=str2double(cell2mat(tmp(2)));
    end
end
fclose(f);
toc
save ValidationSet.mat Y_vali movie_vali
fprintf('ValidationSet finished');
[alpha]=validation(P,Q,num_users,Y_vali,movie_vali,User_attr,Attr,user_mean);


%测试
%------------------说明----------------------------------------------------
%使用test函数作为数据测试，结合基于属性内容的相似性和协同过滤
%--------------------------------------------------------------------------
%alpha表示了基于属性内容的评分所占比例，1-alpha表示了协同过滤方法评分所占的评分
test('test.txt',Attr,User_attr,user_mean,Q,P,num_users,Ymean,alpha);
