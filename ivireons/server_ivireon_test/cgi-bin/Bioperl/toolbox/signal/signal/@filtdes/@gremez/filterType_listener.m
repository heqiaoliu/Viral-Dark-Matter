function filterType_listener(h, varargin)
%FILTERTYPE_LISTENER Overloaded to manage the dynamic properties.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:07:12 $

gremez_filterType_listener(h, varargin{:});

if isspecify(h),
    enab = 'Off';
else
    enab = 'On';
end

enabdynprop(h, 'InitOrder', enab);

% [EOF]
