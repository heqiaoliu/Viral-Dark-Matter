function [boo, offending_name] = utChkforSlashInName(h)
% Check for slashes in names of h and in all objects contained inside h.
% Return true if a slash ('/') is find in any name. 

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $ $Date: 2006/06/27 23:07:07 $

boo = false;
offending_name = '';
if ~isempty(strfind(h.Name,'/'))
    boo = true;
    offending_name = h.Name;
end
