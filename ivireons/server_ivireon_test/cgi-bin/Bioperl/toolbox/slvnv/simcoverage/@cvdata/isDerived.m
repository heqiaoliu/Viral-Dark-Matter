function result = isDerived(Obj)

%Get object ID

%   Copyright 1990-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/19 07:53:32 $
id = Obj.id;

%No short-circuit and cv call may return []
result = (id == 0);
if ~result
	result = cv('get', id, 'testdata.isDerived');
end;
