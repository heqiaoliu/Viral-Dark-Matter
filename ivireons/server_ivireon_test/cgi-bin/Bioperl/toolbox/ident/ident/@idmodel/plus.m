function sys = plus(sys1,sys2)
%PLUS  Addition of two IDMODEL models
%   Requires Control System Toolbox.
%
%   MOD = PLUS(MOD1,MOD2) performs MOD = MOD1 + MOD2.
%   Adding  models is equivalent to connecting
%   them in parallel.
%
%   NOTE: PLUS only deals with the measured input channels.
%   To interconnect also the noise input channels, first convert
%   them to measured channels by NOISECNV.
%
%   The covariance information is lost.
%
%   See also PARALLEL, MINUS, UPLUS.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.3.4.11 $  $Date: 2009/12/05 02:03:10 $

if ~iscstbinstalled
    ctrlMsgUtils.error('Ident:general:cstbRequired','plus')
end

try
    syss1 = ss(sys1('m'));
    syss2 = ss(sys2('m'));
catch E
    throw(E)
end

try
    syss = syss1 + syss2;
catch E
    throw(E)
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

