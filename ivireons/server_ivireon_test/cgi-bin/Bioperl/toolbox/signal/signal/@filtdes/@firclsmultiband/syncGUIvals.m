function syncGUIvals(h, d, arrayh)
%SYNCGUIVALS Sync the specs from the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:18:12 $

specs = whichspecs(h);

fr = whichframes(h);
fr = find(arrayh, '-class', fr.constructor);

for n = 1:length(specs),
	set(d, specs(n).name, evaluatevars(get(fr,specs(n).name)));
end

% [EOF]
