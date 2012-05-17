function rmprops(hParent, varargin)
%RMPROPS Remove dynamic props from an object
%   RMPROPS(H, PROPNAME1, PROPNAME2, etc) Remove the dynamic property
%   PROPNAME1, PROPNAME2, etc from the object H.
%
%   RMPROPS(H, HCHILD) Remove the dynamic properties that are defined by
%   the PROPSTOADD method.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/08/10 02:11:58 $

% If the first input is an object, use its PROPSTOADD method to determine
% which properties should be removed.
if ishandle(varargin{1}),
    props = propstoadd(varargin{1});
else
    
    % If the first input is not an object assume they are strings.
    props = varargin;
    if length(props) == 1 && isempty(props{1}),
        props = {};
    end
end

if isempty(props), return; end

% Loop over all the properties
for indx = 1:length(props)
    
    % Find the property to remove.
    p = findprop(hParent, props{indx});
    
    % Remove the property.
    delete(p);
end

% [EOF]
