function specs = whichspecs(h)
%WHICHSPECS Determine which specs are required for this class.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:17:18 $

% Call super's method
specs = mwv_whichspecs(h);

% Replace default value
indx = find(strcmpi({specs.name},'MagnitudeVector'));

specs(indx) = setfield(specs(indx),'defval',[0 1 0 0]);


