function hout = findhandle(h,arrayh,tag)
%FINDHANDLE Find handle to specified object from array.

%   Author(s): R. Losada & J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2009/01/05 17:59:57 $

% If only a tag was passed in, search the stored array of handles.
if nargin < 3,
    if ~isrendered(h),
        error(generatemsgid('objectNotRendered'), ...
            'Graphical components can only be found after rendering.');
    end
    tag = arrayh;
    arrayh = allchild(h);
end

if ~isempty(arrayh),
    if ~all(ishandle(arrayh)),
        error(generatemsgid('invalidInputs'), 'Handle vector must be specified.');
    end
    if ~iscell(tag), tag = {tag}; end
    
    searchString = {};
    for indx = 1:length(tag)
        searchString = {searchString{:}, 'Tag', tag{indx}, '-or'};
    end
    searchString(end) = [];
    
    hout = find(arrayh, searchString{:}, '-depth', 0);
else
    hout = [];
end

% [EOF]
