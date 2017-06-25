function [alpha]=validation(P,Q,num_users,Y_vali,movie_vali,User_attr,Attr,user_mean)
vali_score1=zeros(num_users,6);
vali_score2=zeros(num_users,6);
tic
for i=1:num_users
    fprintf('%d \r\n',i);
    for j=1:6
        movie=movie_vali(i,j);
        idx=find(Attr(movie,:)==1);
        %[m,~]=find(Attr(:,idx)==1);
		if(isempty(idx)~=1)
            if(length(idx)==1&&User_attr(i,idx(1))~=0)
				vali_score2(i,j)=User_attr(i,idx(1));
			elseif(length(idx)==2&&User_attr(i,idx(1))~=0&&User_attr(i,idx(2))~=0)
				vali_score2(i,j)=(User_attr(i,idx(1))+User_attr(i,idx(2)))/2;
			elseif(length(idx)==2&&User_attr(i,idx(1))==0&&User_attr(i,idx(2))~=0)
				vali_score2(i,j)=User_attr(i,idx(2));
			elseif(length(idx)==2&&User_attr(i,idx(1))~=0&&User_attr(i,idx(2))==0)
				vali_score2(i,j)=User_attr(i,idx(1));
			else
				vali_score2(i,j)=user_mean(i);
			end
        else
			vali_score2(i,j)=user_mean(i);
        end
        vali_score1(i,j)=P(i,:)*Q(:,movie);
    end
end
vali_score1=ceil(vali_score1);
vali_score1=vali_score1*10;
vali_score2=ceil(vali_score2);
vali_score2=vali_score2*10;
toc
tic
for i=1:6
    idx=find(vali_score1(:,i)>100);
    if(size(idx,1)~=0)
        vali_score1(idx,i)=100;
    end
    idx=find(vali_score1(:,i)<0);
    if(size(idx,1)~=0)
        vali_score1(idx,i)=0;
    end
end
for i=1:6
    idx=find(vali_score2(:,i)>100);
    if(size(idx,1)~=0)
        vali_score2(idx,i)=100;
    end
    idx=find(vali_score2(:,i)<0);
    if(size(idx,1)~=0)
        vali_score2(idx,i)=0;
    end
end
toc
save 'valiscore12.mat' vali_score1 vali_score2

alpha=0.1;
l=num_users*6;
scoreall=(1-alpha)*vali_score1+alpha*vali_score2;
scoreall=ceil(scoreall);
err=sqrt(sum(sum((scoreall-Y_vali).^2))/l);
for a=0:0.02:0.5
    fprintf('%d \r\n',a);
	scoreall=(1-a)*vali_score1+a*vali_score2;
    scoreall=ceil(scoreall);
	tmperr=sqrt(sum(sum((scoreall-Y_vali).^2))/l);
    fprintf('%d \r\n',tmperr);
	if(tmperr<err)
		alpha=a;
        err=tmperr;
	end
end
