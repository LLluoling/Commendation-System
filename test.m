function test(outputfile,Attr,User_attr,user_mean,Q,P,num_users,alpha)
item=zeros(num_users,6);
%score=zeros(num_users,6);
f=fopen(outputfile,'rt');
tic
while feof(f)==0
    line=fgetl(f);
    temp=regexp(line,'\|','split');
    t_user=str2double(cell2mat(temp(1)))+1;
    for i=1:6
        line=fgetl(f);
        mov=str2double(line)+1;
        item(t_user,i)=mov;
    end
end
fclose(f);
toc
%目前我存储了目前所有测试数据于'test.mat'
save test.mat item
% load('test.mat');

score1=zeros(num_users,6);
score2=zeros(num_users,6);
%这里调用两种评分的方法 content-based占alpha比重
for i=1:num_users    
    for j=1:6
		mov=item(i,j);
        score1(i,j)=P(i,:)*Q(:,mov);
    end
end
for i=1:num_users
    fprintf('%d \r\n',i);
    for j=1:6
        movie=item(i,j);
        idx=find(Attr(movie,:)==1);
        %[m,~]=find(Attr(:,idx)==1);
		if(isempty(idx)~=1)
            if(length(idx)==1&&User_attr(i,idx(1))~=0)
				score2(i,j)=User_attr(i,idx(1));
			elseif(length(idx)==2&&User_attr(i,idx(1))~=0&&User_attr(i,idx(2))~=0)
				score2(i,j)=(User_attr(i,idx(1))+User_attr(i,idx(2)))/2;
			elseif(length(idx)==2&&User_attr(i,idx(1))==0&&User_attr(i,idx(2))~=0)
				score2(i,j)=User_attr(i,idx(2));
			elseif(length(idx)==2&&User_attr(i,idx(1))~=0&&User_attr(i,idx(2))==0)
				score2(i,j)=User_attr(i,idx(1));
			else
				score2(i,j)=user_mean(i);
			end
        else
			score2(i,j)=user_mean(i);
        end
    end
end
score1=ceil(score1);
score2=ceil(score2);
score1=10*score1;
score2=10*score2;
for i=1:6
    idx=find(score1(:,i)>100);
    if(size(idx,1)~=0)
        score1(idx,i)=100;
    end
    idx=find(score1(:,i)<0);
    if(size(idx,1)~=0)
        score1(idx,i)=0;
    end
end
for i=1:6
    idx=find(score2(:,i)>100);
    if(size(idx,1)~=0)
        score2(idx,i)=100;
    end
    idx=find(score2(:,i)<0);
    if(size(idx,1)~=0)
        score2(idx,i)=0;
    end
end

score=(1-alpha)*score1+alpha*score2;
score=ceil(score);
wr=fopen('output.txt','w');
for i=1:num_users
    str=strcat(num2str(i-1),'|6');
    fprintf(wr,'%s \r\n',str);
    for j=1:6
        str=strcat(num2str(item(i,j)-1),32,32,num2str(score(i,j)));
        fprintf(wr,'%s \r\n',str);
    end
end
fclose(wr);
toc
end
