%load data
%------------------˵��----------------------------------------------------
%ͨ��һ��С����(��ע���е�.py����)���ȶ�train.txt�Լ�itemAttribute.txt���м��飬
%�����û��ĸ�����19835������Ӱ�ĸ�����1624961�����Եĸ�����71878������Χ��9~624951
%��FormMatrix�������ȥ����һ��ϡ����󣬶�ȡ���е�����
%  Y is a 1624961x19835 sparse matrix, containing ratings (0-100) of 1624961 
%  movies on 19835 users
%  R is a 1624961x19835 sparse matrix, where R(i,j) = 1 if and only if user 
% j gave a rating to movie i
%--------------------------------------------------------------------------
num_users=19835; %�����0~19834
num_movies=624961;%�����0~624960
num_atrribute=624952;%����� 9~624951
filename='txt_train.txt';
[Y , R] = FormMatrix(filename,num_movies,num_users);
%pause;
fprintf('Y R finished');
save YR.mat Y  num_users num_movies


%normalize data
%------------------˵��----------------------------------------------------
%ͨ��һ��С���򣬶�ϵ��������й�һ����ʹ��ÿ����Ӱ��ƽ����Ϊ0�����ݳ��ֳ����ȷֲ���״̬
%���������յĽ��������û��ʹ��Ynorm,��������ע���˸öδ���
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
%�����Ҵ洢��Ŀǰ���е�ֵ��'NormalizeData.mat'
%save NormalizeData.mat Ymean Ynorm num_users num_movies num_atrribute
% load('NormalizeData.mat');


%����ֵ�ֽ�
%------------------˵��----------------------------------------------------
%�ⲿ����LFM��ģ��ѵ����ʹ������ݶ��½���ͨ��ѵ�����ҵ����ŵ�����ֵ�ֽ�������
%����õ�P,Q��������matlab̫�����ⲿ��һ����ͬԭ���python������棬����Ϊ��֮
%������У�ֻ��Ҫload������python����ѵ��������PQ��
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

%��������ֵ������
%------------------˵��----------------------------------------------------
%��������һ��ϡ�����洢movie������֮��Ĺ�ϵ
%Attr��һ��num_movies*num_atrattribute�Ĺ�ϵ����
%user_mean��һ���û���ƽ���ֵľ���
%User_attr��һ��ϡ����󣬱�ʾÿ���û������Դ��ƽ����
%--------------------------------------------------------------------------
Attr=attributeGet('itemAttribute.txt',num_movies);
user_mean=zeros(num_users,1);
for i=1:num_users
    idx=find(R(:,i)==1);
    user_mean(i)=sum(Y(idx,i))/length(idx);
end
[User_attr]=GetUser_attr(Y,R,num_atrribute,Attr);
% �����Ҵ洢��Ŀsǰ���е�ֵ��'Attribute.mat'
save Attr.mat Attr User_attr user_mean
load('Attribute.mat');

%validation
%------------------˵��----------------------------------------------------
%ʹ��validation�Ĳ��Լ�
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


%����
%------------------˵��----------------------------------------------------
%ʹ��test������Ϊ���ݲ��ԣ���ϻ����������ݵ������Ժ�Эͬ����
%--------------------------------------------------------------------------
%alpha��ʾ�˻����������ݵ�������ռ������1-alpha��ʾ��Эͬ���˷���������ռ������
test('test.txt',Attr,User_attr,user_mean,Q,P,num_users,Ymean,alpha);
