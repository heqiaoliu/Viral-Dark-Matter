function [L,idx] = findlink(this,linkID)
%FINDLINK  Locates link with given alias.
%
%   L = FINDLINK(D,ALIAS) searches the root node for a data
%   link variable with name ALIAS and returns the corresponding 
%   @variable handle L.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:14:42 $
linkvars = getlinks(this);
if isa(linkID,'hds.variable')
   idx = find(linkvars==linkID);
else
   idx = find(strcmp(linkID,get(linkvars,{'Name'})));
end
if isempty(idx)
   L = [];
else
   L = linkvars(idx);
end