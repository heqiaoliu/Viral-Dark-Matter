function specs = whichspecs(h)
%WHICHSPECS Determine which specs are required for this class.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:16:24 $

% Call super's method
specs = fv_whichspecs(h);

% Replace default value
indx = find(strcmpi({specs.name},'FrequencyVector'));

specs(indx) = setfield(specs(indx),'defval',[0, 8640, 9600, 12000, 12720, 17520,18480,24000]);

