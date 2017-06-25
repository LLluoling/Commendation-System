function [Y,R]=FormMatrix(filename,num_movies,num_users)
f=fopen(filename,'rt');
Y=sparse(num_movies,num_users);
R=sparse(num_movies,num_users);
testi=0;
while feof(f)==0
    line=fgetl(f);
    temp=regexp(line,'\|','split');
    t_user=str2double(cell2mat(temp(1)))+1;
    iter=str2double(cell2mat(temp(2)));
    for i=1:iter
        line=fgetl(f);
        tmp=regexp(line,'\s+','split');
        mov=str2double(cell2mat(tmp(1)))+1;
        Y(mov,t_user)=str2double(cell2mat(tmp(2)))/10;
        R(mov,t_user)=1;
    end
end

end