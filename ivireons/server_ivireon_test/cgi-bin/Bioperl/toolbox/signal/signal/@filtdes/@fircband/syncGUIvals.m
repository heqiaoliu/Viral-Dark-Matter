function syncGUIvals(h, arrayh)
%SYNCGUIVALS

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:04:37 $

hcb = arrayh(isprop(arrayh, 'ConstrainedBands'));

% Set the constrainedbands first since this will change the responsetype
% objects beneath.
if ~isempty(hcb),
    cb = get(hcb, 'ConstrainedBands');
    
    % Make sure that the bands are numeric.
    if ischar(cb), cb = evaluatevars(cb); end
    set(h, 'ConstrainedBands', cb);
end

gremez_syncGUIvals(h, arrayh);

% [EOF]
