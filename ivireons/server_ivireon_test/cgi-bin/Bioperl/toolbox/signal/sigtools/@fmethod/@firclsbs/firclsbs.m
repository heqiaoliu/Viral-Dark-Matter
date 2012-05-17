function this = firclsbs
%FIRCLSBS   Construct an FIRCLSBS object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/23 08:16:52 $

this = fmethod.firclsbs;

set(this, 'DesignAlgorithm', 'FIR Constrained Least-Squares');

% [EOF]
