function Str = describe(Constr, keyword)
%DESCRIBE  Returns Phase Margin constraint description.

%   Author(s): A. Stothert
%   Revised: 
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:01 $

Str = sprintf('Margins');

if (nargin == 2) && strcmp(keyword, 'detail')
    strP   = unitconv(Constr.Data.xCoords, Constr.Data.xUnits, Constr.xDisplayUnits);
    strG   = unitconv(Constr.Data.yCoords, Constr.Data.yUnits, Constr.yDisplayUnits);
    strLoc = unitconv(Constr.Origin, 'deg', Constr.xDisplayUnits);
    gainphase = Constr.Data.Type;
    if strcmp(gainphase,'both')
        Str = sprintf('%s (PM > %0.3g, GM > %0.3g, at %0.3g)', Str, strP, strG, strLoc);
    elseif strcmp(gainphase,'gain')
        Str = sprintf('%s (GM > %0.3g at %0.3g)', Str, strG, strLoc);
    elseif strcmp(gainphase,'phase')
        Str = sprintf('%s (PM > %0.3g at %0.3g)', Str, strP, strLoc);
    else
        Str = sprintf('%s (disabled)', Str);
    end
end
if (nargin == 2) && strcmp(keyword, 'identifier')
    Str = 'GainPhaseMargin';
end
