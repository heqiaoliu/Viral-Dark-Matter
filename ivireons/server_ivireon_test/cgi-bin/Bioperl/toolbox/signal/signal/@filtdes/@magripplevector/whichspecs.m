function specs = whichspecs(h)
%WHICHSPECS Determine which specs are required for this class.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:10:39 $

% Call alternate method
specs = mwv_whichspecs(h);

indx = strcmpi('WeightVector', {specs.name});

specs(indx).name = 'RippleVector';
specs(indx).defval = [.1 .01];

% [EOF]
