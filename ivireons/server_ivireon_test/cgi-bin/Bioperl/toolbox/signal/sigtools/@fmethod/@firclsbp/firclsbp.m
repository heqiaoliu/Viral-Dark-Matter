function this = firclsbp
%FIRCLSBP   Construct an FIRCLSBP object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/23 08:16:51 $

this = fmethod.firclsbp;

set(this, 'DesignAlgorithm', 'FIR Constrained Least-Squares');

% [EOF]
