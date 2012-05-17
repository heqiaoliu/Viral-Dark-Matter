function srcStr = getSourceName(this)
%GETSOURCENAME gets the name of the source.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:51:03 $

hExt = this.Application.getExtInst('Core','General UI');
displ_full_src = get(findProp(hExt,'DisplayFullSourceName'),'value');
if displ_full_src
    srcStr = this.Name;
else
    srcStr = this.NameShort;
end
end
