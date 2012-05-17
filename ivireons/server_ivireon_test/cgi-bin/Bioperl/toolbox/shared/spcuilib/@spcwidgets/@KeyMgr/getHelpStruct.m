function helpStruct = getHelpStruct(hKeyMgr)
%GETHELPSTRUCT Return vector of structs describing key help.
%   GETHELPSTRUCT(H) returns a vector of structs containing the fields:
%   .Title: title of next section of key help
%   .Mapping: a cell-array passed to DDG2ColText
%          {'key1', 'description1', enable1; ...
%           'key2', 'description2', enable2; }
%   Column 1 is the name of the key (keys)
%   Column 2 is a brief description of the action take for the
%      corresponding key (keys)
%   Ex:
%      s.'Title' = 'Navigation commands';
%      s.Mapping = ...
%          {'n',  'Go to next entry', true; ...
%           'p',  'Go to previous entry',true};

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2008/02/02 13:11:44 $

helpStruct=[];
hc=hKeyMgr.down;
while ~isempty(hc)
    helpStruct=[helpStruct;getHelpStruct(hc)]; %#ok
    hc=hc.right;
end

% [EOF]
