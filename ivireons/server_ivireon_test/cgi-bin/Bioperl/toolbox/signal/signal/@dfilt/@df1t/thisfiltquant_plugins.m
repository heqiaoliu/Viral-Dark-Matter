function constr = thisfiltquant_plugins(h,arith)
%FILTQUANT_PLUGINS Table of filterquantizer plugins

%   Author(s): R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2009/07/14 04:01:21 $

switch arith
    case 'fixed',
        constr = 'quantum.fixeddf1tfilterq';
end
