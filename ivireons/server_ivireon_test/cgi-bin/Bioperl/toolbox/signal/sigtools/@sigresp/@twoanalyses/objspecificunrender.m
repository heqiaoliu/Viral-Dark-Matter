function objspecificunrender(hObj)
%OBJSPECIFICUNRENDER

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/01/05 18:01:58 $

hresps = get(hObj, 'Analyses');

% Unrender each of the contained Analyses.
if isrendered(hresps(1)), unrender(hresps(1)); end
if isrendered(hresps(2)), unrender(hresps(2)); end

h = get(hObj, 'Handles');

% We do not want to delete the axes and the cline is taken care of by the
% contained response objects.
h = convert2vector(rmfield(h, 'cline'));
h(~ishghandle(h)) = [];

delete(h);

% [EOF]
