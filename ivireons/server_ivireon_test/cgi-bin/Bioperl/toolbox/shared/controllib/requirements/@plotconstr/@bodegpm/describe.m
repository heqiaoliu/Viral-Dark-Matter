function Str = describe(Constr, keyword)
%DESCRIBE  Returns Phase Margin constraint description.

%   Author(s): A. Stothert
%   Revised: 
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:28 $

Str = sprintf('Gain & Phase margins');
if (nargin == 2) && strcmp(keyword, 'detail')
    Str = sprintf('Requirement: ');
    MarginPha  = Constr.Data.getData('xData');
    MarginGain = Constr.Data.getData('yData');
    gainphase  = Constr.Data.getData('type');
    if strcmp(gainphase,'gain') || strcmp(gainphase,'both')
        strGM = unitconv(MarginGain, Constr.Data.getData('yUnits'), Constr.yDisplayUnits);
        Str = sprintf('%s \n GM > %0.3g', Str, strGM);
    end
    if strcmp(gainphase,'phase') || strcmp(gainphase,'both')
        strPM = unitconv(MarginPha, Constr.Data.getData('xUnits'), Constr.xDisplayUnits);
        Str = sprintf('%s \n PM > %0.3g', Str, strPM);
    end
end
if (nargin == 2) && strcmp(keyword, 'identifier')
    Str = 'GPMargins';
end