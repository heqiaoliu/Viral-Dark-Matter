function b = issfmaskedsubsystem(blk)
%ISSFMASKEDSUBSYSTEM(BLK)   True if the object is sfmaskedsubsystem(blk).

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:58:01 $

b = blk.isMasked && isequal('Stateflow', blk.MaskType);

% [EOF]
