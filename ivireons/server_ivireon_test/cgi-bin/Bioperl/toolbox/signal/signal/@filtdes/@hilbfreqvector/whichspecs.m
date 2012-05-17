function specs = whichspecs(h)
%WHICHSPECS Determine which specs are required for this class.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:17:00 $

% Call super's method
specs = fv_whichspecs(h);

% Replace default value
indx = find(strcmpi({specs.name},'FrequencyVector'));

specs(indx) = setfield(specs(indx),'defval',[2400 21600]);

