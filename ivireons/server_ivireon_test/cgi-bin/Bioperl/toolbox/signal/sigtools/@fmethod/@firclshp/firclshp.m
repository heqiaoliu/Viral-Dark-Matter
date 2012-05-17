function this = firclshp
%FIRCLSHP   Construct an FIRCLSHP object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:42 $

this = fmethod.firclshp;

set(this, 'DesignAlgorithm', 'FIR Constrained Least-Squares');

% [EOF]
