function this = firclslp
%FIRCLSLP   Construct an FIRCLSLP object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:47 $

this = fmethod.firclslp;

set(this, 'DesignAlgorithm', 'FIR constrained least-squares');

% [EOF]
