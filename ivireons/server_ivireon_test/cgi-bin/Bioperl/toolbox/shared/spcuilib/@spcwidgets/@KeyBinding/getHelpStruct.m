function helpStruct = getHelpStruct(hBinding,parentName,parentEnable, parentVisible)
%GETHELPSTRUCT Return vector of structs describing key help.
%   GETHELPSTRUCT(H) returns a vector of structs containing the fields:
%   .Title: title of next section of key help
%   .Mapping: a cell-array passed to DDG2ColText
%          {'key1', 'description1', enable1, visible1; ...
%           'key2', 'description2', enable2, visible2; }
%   Column 1 is the name of the key (keys)
%   Column 2 is a brief description of the action take for the
%      corresponding key (keys)
%   Column 3 is a logical flag indicating enable state
%   Ex:
%      s.Title = 'Navigation commands';
%      s.Mapping = ...
%          {'n',  'Go to next entry', true, true; ...
%           'p',  'Go to previous entry', true, true};
%
% Key considerations:
%    1) If .Help is empty, do not return help for this entry
%       Instead, return an empty
%       This is done when two or more help entries are to be combined,
%       and another entry has done the combining of Id's and Help text.
%    2) Use .KeyId string only if .HelpId is empty
%       Otherwise, take .HelpId as the string describing the key/keys
%    3) If .HelpGroup is empty, use parent ParentName argument.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/05/23 08:12:24 $

% Get help description
desc = hBinding.Help;

if isempty(desc)
    helpStruct = [];
else
    % .KeyId is used only if .HelpId is empty
    id = hBinding.HelpId;
    if isempty(id)
        id = hBinding.KeyId;
    end
    id = firstCap(id);
    if iscellstr(id)
        % concatenate contents of cell-vector of strings
        % ex: {'a','b'} -> 'a, b'
        id = sprintf('%s, ', id{:});
        id = id(1:end-2);
    end
    
    % Parent's .Name is used only if .HelpGroup is empty
    title = hBinding.HelpGroup;
    if isempty(title)
        title = parentName;
    end

    % Enable state of binding
    ena =  strcmpi(hBinding.Enabled,'on') ...
        && strcmpi(parentEnable,'on');
    
    % visible state of binding
    visible =  strcmpi(hBinding.Visible,'on') ...
        && strcmpi(parentVisible,'on');
    
    helpStruct = struct('Title',title,'Mapping',{{id,desc,ena, visible}});
end

%-------------------------------------------------------------------------
function y = firstCap(y)
if iscell(y)
    for i=1:numel(y)
        yi=y{i};
        if ~isempty(y)
            yi(1)=upper(yi(1));
            y{i} = yi;
        end
    end
else
    if ~isempty(y)
        y(1)=upper(y(1));
    end
end

% [EOF]
