function constr = thisfiltquant_plugins(h,arith)
%FILTQUANT_PLUGINS Table of filterquantizer plugins

%   Author(s): R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/07/27 20:29:16 $

switch arith
    case 'fixed',
        [wstr wid] = lastwarn;
        w = warning('off');
        if legacyfixptfir,
            constr = 'quantum.fixedfirfilterqwtapsum';
        else
            constr = 'quantum.fixeddfsymfirfilterq';
        end
        lastwarn(wstr, wid)
        warning(w);
end
