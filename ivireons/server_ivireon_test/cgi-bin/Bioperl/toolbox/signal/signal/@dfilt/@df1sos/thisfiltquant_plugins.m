function constr = thisfiltquant_plugins(h,arith)
%FILTQUANT_PLUGINS Table of filterquantizer plugins

%   Author(s): R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/07/14 04:01:16 $

switch arith
    case 'fixed',
        constr = 'quantum.fixeddf1sosfilterq';
end
