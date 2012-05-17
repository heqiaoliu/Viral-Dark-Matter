function parforstart
%PARFORSTART                     Private utility function for parallel

%PARFORSTART  Called before starting a PARFORLOOP.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2007/05/14 15:08:05 $

parfor_depth( parfor_depth + 1 );

