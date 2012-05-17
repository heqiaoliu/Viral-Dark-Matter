function s = savepublicinterface(this)
%SAVEPUBLICINTERFACE   Save the public interface.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:05:32 $

s = abstract_savepublicinterface(this);

s.BlockLength         = get(this, 'BlockLength');
s.NonProcessedSamples = get(this, 'NonProcessedSamples');

% [EOF]
