function TableData = createtablecell(this,VarNames,VarData) %#ok<*INUSL>
%CREATETABLECELL Creates table data

%   Author(s): R. Chen
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:21:51 $

Nsys = length(VarData);
TableData = javaArray('java.lang.Object',Nsys,3);

for cnt=1:Nsys
    sys = VarData{cnt};
    sysclass = class(sys);
    TableData(cnt,1) = java.lang.String(VarNames{cnt});
    TableData(cnt,2) = java.lang.String(sysclass);
    if any(strcmp(sysclass, {'idss','idarx','idgrey','idproc','idpoly','idfrd'}))
        TableData(cnt,3) = java.lang.String('');
    else
        TableData(cnt,3) = java.lang.String(num2str(size(sys,'order')));
    end    
end
