function h = getkeyhandles(this)
%GETKEYHANDLES Returns the handles to the objects which will cause an
%unrender.  When any of these handles are deleted, the entire object will
%unrender.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/12/26 22:22:55 $

h = get(this, 'Handles');

if isfield(h, 'legend')
    h = rmfield(h, 'legend');
end

h = convert2vector(h);

% [EOF]
