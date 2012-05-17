function h = butteralp
%BUTTERALP   Construct a BUTTERALP object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:49:59 $

h = fmethod.butteralp;
set(h,'DesignAlgorithm','Butterworth');

% [EOF]
