function parforend
%PARFOREND                       Private utility function for parallel

%PARFOREND  Called after termination of a PARFOR.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2007/05/14 15:08:02 $

parfor_depth( parfor_depth - 1 );
