function name = unique_name_for_list(objs, classType)
% NAME = UNIQUE_NAME_FOR_LIST( OBJS, CLASSTYPE )

%	Jay R. Torgerson
%	Copyright 1995-2008 The MathWorks, Inc.
%  $Revision: 1.12.2.4 $

switch(classType)
    case 'data'
        base = sf('get','default','data.name');
    case 'event'
        base = sf('get','default','event.name');
    case 'target'
        base = sf('get','default','target.name');
    case 'trigger'
        base = 'trigger';
    case 'function_call'
        base = 'fcncall';
    otherwise
        base = 'untitled';
end;

true = 1;
false = 0;

ind = 0;
indStr = '';
unique = false;

while(unique == false),
    unique = true;
    name = [base,indStr];
    for o = objs(:)',
        oName = sf('get', o, '.name');
        if (strcmp(name,oName)), unique = false; end;
    end;
    ind=ind+1;
    indStr = int2str(ind);
end;


