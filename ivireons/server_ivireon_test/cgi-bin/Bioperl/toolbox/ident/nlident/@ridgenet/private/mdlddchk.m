function msg = mdlddchk(wghts, regdim)
%MDLDDCHK: model and data consistency check

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/06/13 15:25:12 $

% Author(s): Qinghua Zhang


[nlregdim, nbunits] = size(wghts.Dilation);

msg = struct([]);

if nlregdim~=size(wghts.NonLinearSubspace,2)
    msg = 'Model parameters have inconsistent dimensions.';
    msg = struct('identifier','Ident:utility:modelParInconsistency','message',msg);
    return
end

linregdim = size(wghts.LinearCoef,1);
if linregdim~=size(wghts.LinearSubspace,2)
    msg = 'Model parameters have inconsistent dimensions.';
    msg = struct('identifier','Ident:utility:modelParInconsistency','message',msg);
    return
end

if regdim~=size(wghts.LinearSubspace,1)
    msg = 'Data dimension is inconsistent with model structure.';
    msg = struct('identifier','Ident:utility:dataModelStrucInconsistency','message',msg);
    return
end

% FILE END