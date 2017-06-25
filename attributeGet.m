% function [Attr]=attributeGet(filename,num_movies)
function [Attr]=attributeGet()
num_movies=1624961;
num_atrribute=624952;
Attr=sparse(num_movies,num_atrribute);
f=fopen('itemAttribute.txt','rt');
while feof(f)==0
    line=fgetl(f);
    temp=regexp(line,'\|','split');
    a1=cell2mat(temp(1));
    a2=cell2mat(temp(2));
    a3=cell2mat(temp(3));
    if(strcmp(a2,'None')==1)
        continue;
    else
        Attr(str2double(a1)+1,str2double(a2))=1;
        if(strcmp(a3,'None')==1)
            continue;
        else
            Attr(str2double(a1)+1,str2double(a3))=1;
        end         
    end
end