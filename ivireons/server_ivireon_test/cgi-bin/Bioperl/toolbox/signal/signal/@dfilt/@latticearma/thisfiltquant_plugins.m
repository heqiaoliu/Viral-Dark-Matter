function constr = thisfiltquant_plugins(h,arith)
%FILTQUANT_PLUGINS Table of filterquantizer plugins

%   Author(s): V. Pellissier
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/07/14 04:03:05 $

switch arith
    case 'fixed',
        constr = 'quantum.fixedlatticearmafilterq';
end
