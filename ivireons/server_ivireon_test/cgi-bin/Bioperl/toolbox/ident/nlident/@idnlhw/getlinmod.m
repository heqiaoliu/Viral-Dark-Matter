function linsys = getlinmod(sys)
%GETLINMOD Extract the linear sub-model of an IDNLHW model.
%
%  LINMDL = GETLINMOD(NLMDL) extracts the linear sub-model of the IDNLHW model 
%  NLMDL and returns the result in LINMDL as an IDPOLY object for a single
%  output model, or as an IDSS object for a multiple outputs model.
%
%  See also idnlhw/linapp, idnlhw/linearize.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/12/05 02:04:39 $

% Author(s): Qinghua Zhang

[ny, ~] = size(sys);

if ny==1
    linsys = idpoly(1,pvget(sys, 'b'),'f', pvget(sys, 'f'));
    linsys = pvset(linsys,'BFFormat',-1);
else
    linsys  = numden2idss(pvget(sys, 'b'), pvget(sys, 'f'), pvget(sys, 'Ts'));
end

% Inputs
linsys = pvset(linsys, 'InputName', pvget(sys, 'InputName'));
linsys = pvset(linsys, 'InputUnit', pvget(sys, 'InputUnit'));

% Outputs
linsys = pvset(linsys, 'OutputName', pvget(sys, 'OutputName'));
linsys = pvset(linsys, 'OutputUnit', pvget(sys, 'OutputUnit'));

%Ts
linsys = pvset(linsys, 'Ts',  pvget(sys, 'Ts'));
linsys = pvset(linsys, 'TimeUnit', pvget(sys, 'TimeUnit'));

linsys.EstimationInfo.Status = 'Extracted from an IDNLHW model';
% FILE END
