function nk = findnk(a,b,d)
%FINDNK  find delay (nk) in idss model by inspecting structure matrices

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $ $Date: 2008/10/02 18:51:17 $

nu=size(b,2);
if nu ==0
    nk = [];
end
k=1;
if ~any(any(isnan(a)'))&&~any(any(isnan(b)'))&&~any(any(isnan(d)')) %%LL%% Check this WHY?
    for ku=1:nu
        nk(ku) = norm(d(:,ku))==0;
    end
    return
end

for ku=1:nu
    if any(isnan(b(:,ku)))||isempty(a)
        temp =~any(isnan(d(:,ku)));
        nk(ku)=+temp;
    else
        nk(ku)=-1;
        j(k)=find(b(:,ku)==1);
        k=k+1;
    end
end
j(k)=size(b,1)+1;
if k>1
    nk(find(nk==-1))=diff(j)+1;
end

%nk=ones(1,size(b,2));
