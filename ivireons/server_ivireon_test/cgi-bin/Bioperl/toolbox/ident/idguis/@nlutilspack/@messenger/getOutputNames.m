function ynames = getOutputNames(h,datatype)
%Obtain cell array of output name strings for estimation or validation
%data.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:50:51 $

if nargin<2
    datatype = 'estimation';
end

if strcmpi(datatype,'estimation')
    z = h.getCurrentEstimationData;
elseif strcmpi(datatype,'validation')
    z = h.getCurrentValidationData;
else
    ctrlMsgUtils.error('Ident:idguis:getNames1','getOutputNames(h,DATATYPE)')
end

ynames = pvget(z,'OutputName');
