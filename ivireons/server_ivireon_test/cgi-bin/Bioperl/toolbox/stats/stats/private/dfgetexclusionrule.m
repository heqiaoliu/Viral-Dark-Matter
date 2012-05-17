function hExcl = dfgetexclusionrule(ename)
%GETEXCLUSIONRULE Get an exclusion rule by name

% $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:28:55 $
% Copyright 2003-2004 The MathWorks, Inc.

db = getoutlierdb;
hExcl = find(db,'name',ename);

