function TableData = createtablecell(this,VarNames,VarData)
%CREATETABLECELL Creates table data

%   Author(s): Craig Buhr
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2006/12/27 20:34:06 $

Nsys = length(VarData);
TableData = javaArray('java.lang.Object',Nsys,3);

for cnt=1:Nsys
    sys = VarData{cnt};
    sysclass = class(sys);
    TableData(cnt,1) = java.lang.String(VarNames{cnt});
    TableData(cnt,2) = java.lang.String(sysclass);

    if any(strcmp(sysclass, {'idpoly','idss','idarx'}))
        TableData(cnt,3) = java.lang.String('');
    else
        TableData(cnt,3) = java.lang.String(num2str(size(sys,'order')));
    end    
end
