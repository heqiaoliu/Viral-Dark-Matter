function subselects = getsubselections(hSct, tag)
%GETSUBSELECTIONS Returns all subselections for a given selection
%   GETSUBSELECTIONS(hSCT) Returns all subselections for the current selection
%
%   GETSUBSELECTIONS(hSCT, TAG) Returns all subselections for the selection
%   specified by the string TAG.

%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2007/12/14 15:19:17 $

% This can be a private method

error(nargchk(1,2,nargin,'struct'));

identifiers = get(hSct, 'Identifiers');
selections  = getallselections(hSct);

if nargin == 1,
    tag = get(hSct,'Selection');
end

if isempty(tag),
    subselects = {''};
    return
end

% Find the referenced selection
indx = strmatch(tag, selections);

switch length(indx),
case 0
    msg = 'Selection not found.';
case 1
    msg = '';
    if iscell(identifiers{indx}),
        subselects = {identifiers{indx}{2:end}};
    else
        subselects = {};
    end    
otherwise
    msg = ['Selection is not specific enough.  Found these matches:' char(10)];
    for i = 1:length(indx)
        msg = [msg char(9) '''' selections{indx(i)} ''''];
    end
end

if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

% [EOF]
