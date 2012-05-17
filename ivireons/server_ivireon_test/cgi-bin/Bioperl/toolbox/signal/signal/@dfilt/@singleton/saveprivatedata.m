function s = saveprivatedata(this)
%SAVEPRIVATEDATA   Save the private data.

%   Author(s): J. Schickler
%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:59:43 $

s = base_saveprivatedata(this);

s.privnormGain = get(this, 'privnormGain');

% [EOF]
