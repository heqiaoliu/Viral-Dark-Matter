function constr = filtquant_plugins(h,arith)
%FILTQUANT_PLUGINS Table of filterquantizer plugins

%   Author(s): R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/07/27 20:28:45 $

switch arith
    case 'double',
        %#function dfilt.filterquantizer
        constr = 'dfilt.filterquantizer';
    case 'single',
        %#function dfilt.singlefilterquantizer
        constr = 'dfilt.singlefilterquantizer';
    otherwise,
        constr = thisfiltquant_plugins(h,arith);
end
