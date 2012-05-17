function constr = thisfiltquant_plugins(h,arith)
%FILTQUANT_PLUGINS Table of filterquantizer plugins

%   Author(s): V. Pellissier
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/07/14 04:00:36 $

switch arith
    case 'fixed',
        constr = 'quantum.fixedlatticefilterq';
end
