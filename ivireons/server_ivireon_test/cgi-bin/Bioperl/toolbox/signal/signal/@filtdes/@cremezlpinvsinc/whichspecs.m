function specs = whichspecs(h)
%WHICHSPECS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:15:39 $

specs = ft_whichspecs(h);

newspecs.name     = 'invSincFreqFactor';
newspecs.datatype = 'udouble';
newspecs.defval   = 1;
newspecs.callback = [];
newspecs.descript = 'magspec';

specs = [newspecs specs];

% [EOF]
