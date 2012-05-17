function DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
%DGDFGEN Generates the dg_dfilt structure

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/07/14 04:01:04 $

DGDF = delaydggen(Hd.filterquantizer,Hd,hTar.privStates);

% [EOF]
