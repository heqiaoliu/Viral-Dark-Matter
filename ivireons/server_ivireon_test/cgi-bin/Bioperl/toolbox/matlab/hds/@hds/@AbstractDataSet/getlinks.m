function L = getlinks(this)
%GETLINKS  Gathers data link variables.
%
%   L = GETLINKS(D) returns the list L of data link
%   variables in the root node D.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 18:13:29 $
% L = get(this.Children_,{'Alias'});
% L = cat(1,L{:});
L = this.Cache_.Links;
