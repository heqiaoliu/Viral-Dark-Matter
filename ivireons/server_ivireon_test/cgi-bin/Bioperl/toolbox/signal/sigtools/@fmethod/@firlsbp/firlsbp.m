function this = firlsbp
%FIRLSBP   Construct a FIRLSBP object.

%   Author(s): J. Schickler
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:40:03 $

this = fmethod.firlsbp;

set(this, 'DesignAlgorithm', 'FIR Least-Squares');

% [EOF]
