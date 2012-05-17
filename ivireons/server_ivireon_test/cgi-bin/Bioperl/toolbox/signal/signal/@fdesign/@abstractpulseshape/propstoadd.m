function p = propstoadd(this)
%PROPSTOADD   Return the properties to add to the parent object.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/02/13 15:13:42 $

p = propstoadd(this.CurrentSpecs);

p = [{'Description', 'SamplesPerSymbol'}, p];

% [EOF]
