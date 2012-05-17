function p = isValidPointerBehavior(pb)
%isValidPointerBehavior Check validity of pointer behavior struct.
%   isValidPointerBehavior(pb) returns true if pb is a valid pointer behavior
%   struct used by iptSetPointerBehavior, iptGetPointerBehavior, and
%   iptPointerManager. 
%
%   See also iptGetPointerBehavior, iptPointerManager, iptSetPointerManager.

%   Copyright 2005-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/09/18 02:27:35 $

% A valid pointer behavior is a scalar struct with the fields enterFcn,
% traverseFcn, and exitFcn. The value of each field must be a
% function_handle.

p = isscalar(pb) && ...
    isstruct(pb) && ...
    hasFunctionHandleField(pb, 'enterFcn') && ...
    hasFunctionHandleField(pb, 'traverseFcn') && ...
    hasFunctionHandleField(pb, 'exitFcn');

function p = hasFunctionHandleField(s, fieldName)

p = isfield(s, fieldName) && ...
   (isempty(s.(fieldName)) || isa(s.(fieldName), 'function_handle'));
