function sys = mtimes(sys1,sys2)
%MTIMES  Multiplication of IDMODELS.
%   Requires Control System Toolbox.
%
%   MOD = MTIMES(MOD1,MOD2) performs MOD = MOD1 * MOD2.
%   Multiplying two LTI models is equivalent to
%   connecting them in series as shown below:
%
%         u ----> MOD2 ----> MOD1 ----> y
%
%   NOTE: MTIMES  only deals with the measured input channels.
%   To interconnect also the noise input channels, first convert
%   them to measured channels by NOISECNV.
%
%   The covariance information is lost.
%   See also SERIES, INV.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.3.4.7 $  $Date: 2009/12/05 02:03:08 $

try
    syss1 = ss(sys1('m'));
    syss2 = ss(sys2('m'));
catch E
    throw(E)
end

try
    syss = syss1 * syss2;
catch E
    throw(E)
end

names = [syss.InputName;syss.OutputName];
if length(unique(names))<length(names)
    syss.InputName = defnum([],'u',size(syss,2));
    syss.OutputName = defnum([],'y',size(syss,1));
end

switch class(sys1)
    case {'idss','idarx','idgrey','idproc'}
        sys = idss(syss);
    case{'idpoly'}
        CellFormat = pvget(sys1,'BFFormat');
        if isa(sys2,'idpoly')
            CellFormat = max(CellFormat,pvget(sys2,'BFFormat'));
        end
        sys = idpoly(syss,'BFFormat',CellFormat);
end
