function h = butterahp
%BUTTERAHP   Construct a BUTTERAHP object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:49:53 $

h = fmethod.butterahp;
set(h,'DesignAlgorithm','Butterworth');

% [EOF]
