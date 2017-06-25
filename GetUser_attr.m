function [User_attr]=GetUser_attr(Y,R,num_atrribute,Attr)
num_users=19835;
User_attr=sparse(num_users,num_atrribute);
tic
for i=1:num_atrribute
    idx=find(Attr(:,i)==1);
    if(isempty(idx)~=1)
        fprintf('%d \r\n',i);
        u_count=zeros(num_users,1);
        for j=1:length(idx)
           u_t= find(R(idx(j),:)==1);
           User_attr(u_t,i)=User_attr(u_t,i)+Y(idx(j),u_t)';
           u_count(u_t)=u_count(u_t)+1;
        end
        tmp=find(u_count~=0);
        User_attr(tmp,i)=User_attr(tmp,i)./u_count(tmp);
    end
end
toc