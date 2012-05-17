function hc = findChild(this, varargin)
%FINDCHILD Find the specified child object.
%   FINDCHILD(H, Param1, Value1, etc.) Find the child object in the
%   database H that matches Param1, Value1, etc.  This method will return
%   [] when no child is found to match the inputs.  It will return a vector
%   of objects when multiple objects are found to match the inputs.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:45:48 $

cClass = getChildClass(this);

% Find the child based on the specified PV pairs.
if strcmpi(cClass, 'handle')
    hc = find(this, '-depth', 1, varargin{:});
else
    hc = find(this, '-depth', 1, '-isa', getChildClass(this), varargin{:});
end

% If the first element is the database remove it from the list.  This can
% happen when getChildClass is an abstract class, Database or handle.
% These are valid child classes because databases can contain other
% databases.
if ~isempty(hc) && hc(1) == this
    hc(1) = [];
end

% [EOF]
