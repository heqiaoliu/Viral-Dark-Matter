function strs = getsubstrings(hSct, tag)
%GETSUBSTRINGS Returns the labels for the subselection

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2007/12/14 15:19:18 $

error(nargchk(1,2,nargin,'struct'));

if nargin == 1, tag = get(hSct,'Selection'); end

if isempty(tag),
    strs = {''};
    return
end

strings    = get(hSct, 'Strings');
selections = getallselections(hSct);

% Find the referenced selection, use strmatch for partial string completion
indx = strmatch(tag, selections);

switch length(indx),
case 0
    msg = 'Selection not found.';
case 1
    selections = get(hSct, 'Identifiers');
    msg = '';
    
    % There are only substrings if the strings at indx are a cell
    if iscell(strings{indx}),
        strs = strings{indx}(1:end);
        
        % If the length of the strings and tags are the same the first
        % string is the radio label, do no return it.
        if ~difference(hSct, indx),
            strs = strs(2:end);
        end
    else
        strs = {};
    end    
otherwise
    msg = ['Selection is not specific enough.  Found these matches:' char(10)];
    for i = 1:length(indx)
        msg = [msg char(9) '''' selections{indx(i)} ''''];
    end
end

if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

% [EOF]
