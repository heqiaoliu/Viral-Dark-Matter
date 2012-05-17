function helpStruct = getHelpStruct(hGroup)
%GETHELPSTRUCT Return vector of structs describing key help.
%   GETHELPSTRUCT(H) returns a vector of structs containing the fields:
%   .Title: title of next section of key help
%   .Mapping: a cell-array passed to DDG2ColText
%          {'key1', 'description1', enable1, visible1; ...
%           'key2', 'description2', enable2, visible2; }
%   Column 1 is the name of the key (keys)
%   Column 2 is a brief description of the action take for the
%      corresponding key (keys)
%   Ex:
%      s.Title = 'Navigation commands';
%      s.Mapping = ...
%          {'n',  'Go to next entry',true, true; ...
%           'p',  'Go to previous entry',true, true};

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/05/23 08:12:26 $

helpStruct=[];
hc=hGroup.down;
while ~isempty(hc)
    helpStruct = [helpStruct; ...
                  getHelpStruct(hc, hGroup.Name, hGroup.Enable, hGroup.Visible)]; %#ok
    hc=hc.right;
end

% [EOF]
