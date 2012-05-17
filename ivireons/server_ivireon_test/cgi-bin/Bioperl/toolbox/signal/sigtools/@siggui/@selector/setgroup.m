function setgroup(hSct, varargin)
%SETGROUP Change a group in the selector
%   SETGROUP(hSCT, TAG, NEWTAGS, NEWSTRS) Change a popupmenu group in the selector
%   which is identified by TAG.  NEWTAGS stores the new identifiers for the selections
%   within the popup and NEWSTRS stores the new strings for the selections within the
%   popup.  Only subselections can be changed through this method.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.3 $  $Date: 2007/12/14 15:19:22 $

% Parse and validate the inputs
[tag, tags, strings, msg] = parse_inputs(hSct, varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

selections = getallselections(hSct);
indx       = strmatch(tag, selections);

switch length(indx)
case 0
    msg = 'That selection is not available.';
case 1
    alltags    = get(hSct, 'Identifiers');
    allstrings = get(hSct, 'Strings');
    
    if iscell(alltags{indx})
        indx2   = find(strcmpi(hSct.SubSelection, alltags{indx}(2:end)))-difference(hSct, indx)+1;
        if isempty(indx2),
            cstring = '';
        else
            cstring = allstrings{indx}{indx2};
        end
        
    else
        cstring = '';
    end
    % Make sure that the radio button label is not being changed
    msg              = '';
    
    % If the tags and indexes are of the same size, then we want to retain
    % the first string (the label to the radio button)
    if ~difference(hSct, indx),
        if iscell(allstrings{indx})
            newstr = [allstrings{indx}(1) strings];
        else
            newstr = [{allstrings{indx}} strings];
        end
    else
        newstr = strings;
    end
    
    if iscell(alltags{indx}),
        alltags{indx} = [alltags{indx}(1) tags];
    else,
        if length(tags) == length(strings),
            alltags{indx} = [{alltags{indx}} tags];
        else
            alltags{indx} = tags;
        end
    end
    
    allstrings{indx} = newstr;
otherwise
    msg = 'Input selection is not specific.  Found these possible matches:';
    msg = [msg char(10)];
    for i = 1:length(indx)
        msg = [msg '  ''' selections{indx(i)} ''''];
    end
end

if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

set(hSct, 'Identifiers', alltags);
set(hSct, 'Strings', allstrings);

% Make sure that the subselection is still valid.
if strcmpi(hSct.Selection, tag),
    subselect = get(hSct, 'SubSelection');
    if isempty(find(strcmpi(subselect, tags))),
        
        % Make sure the string is unavailable too.
        cindx = find(strcmpi(cstring, allstrings{indx}));
        if isempty(cindx)
            set(hSct, 'subselection', tags{1});
        else
            
            % If the string is still available use it.
            set(hSct, 'subselection', alltags{indx}{cindx});
        end
    end
end

if isrendered(hSct),
    update(hSct, 'update_popup');
end


% ---------------------------------------------------------------------
function [tag, tags, strs, msg] = parse_inputs(hSct, varargin)

msg = nargchk(4,4,nargin);

if isempty(msg)
    tag  = varargin{1};
    tags = varargin{2};
    strs = varargin{3};
    
    msg = validate_inputs(tags, strs);
end


% --------------------------------------------------------------------
function msg = validate_inputs(tags, strs);

msg = '';

if ~any(length(tags)-length(strs) == [0 1]),
    msg = 'New identifiers and strings must be of the same length.';
end

% [EOF]
