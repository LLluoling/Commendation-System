function [J, grad] = CostFunc(params,Y, R, num_users,num_movies,num_features,lambda1,lambda2)

Q = reshape(params(1:num_movies*num_features), num_movies, num_features);
P = reshape(params(num_movies*num_features+1:end), ...
                num_users, num_features);
%Q是movie*feature
%P是user*feature
J = 0;
Q_grad = zeros(size(Q));
P_grad = zeros(size(P));
%对所有R为1的值计算cost函数
fprintf('begin.... \r\n');
tic
%先是计算cost函数
J_1=0;
for i=1:num_users
    idx=find(R(:,i)==1);
    if(~isempty(idx))
        Y_tmp=Y(idx,i);
        J_1=J_1+sum((Q(idx,:)*P(i,:)'-Y_tmp).^2); 
    end
end
% [m,n]=find(R(:,:)==1);
% tt=sub2ind(size(R),m,n);
% J_1=sum((Q(m,:)*P(n,:)'-Y(tt)).^2); 

J_2=sum(sum(P.^2))*lambda1/2;
J_3=sum(sum(Q.^2))*lambda2/2;
J=J_1+J_2+J_3;

%使用SGD的梯度下降？？？？？？速度更快
tic
for i=1:num_movies
    idx=find(R(i,:)==1);
    if(isempty(idx)~=1)
        Ptmp=P(idx,:);
        Ytmp=Y(i,idx);
        Q_grad(i,:)=(Q(i,:)*Ptmp'-Ytmp)*Ptmp+lambda2*Q(i,:);
    end
end
toc
for j=1:num_users
    idx=find(R(:,j)==1);
    Qtmp=Q(idx,:);
    Ytmp=Y(idx,j);
    P_grad(j,:)=(Qtmp*P(j,:)'-Ytmp)'*Qtmp+lambda1*P(j,:);
end

% [x,y]=find(R(:,:)==1); 
% for i=1:length(x)
%     fprintf('%d',i);
%     err=Q(x(i),:)*P(y(i),:)'-Y(x(i),y(i));
%     Q_grad(x(i),:)=Q_grad(x(i),:)+err*Q(x(i),:)+lambda2*P(y(i),:);
%     P_grad(y(i),:)=P_grad(y(i),:)+err*P(y(i),:)+lambda1*Q(x(i),:);
% end
toc
fprintf('end.... \r\n');

%梯度下降
% [x,y]=find(R(:,:)==1);
% z=sub2ind(size(R),x,y);
% err=2*(Q(x,:)*P(y,:)'-Y(z));
% Q_grad(x,:)=err*P(y,:)+lambda2*Q(x,:);
% P_grad(y,:)=err*Q(x,:)+lambda1*P(y,:);

grad = [Q_grad(:); P_grad(:)];

end


