function unames = getInputNames(this,datatype)
%Obtain cell array of input name strings for estimation or validation data

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:50:50 $

if nargin<2
    datatype = 'estimation';
end

if strcmpi(datatype,'estimation')
    z = this.getCurrentEstimationData;
elseif strcmpi(datatype,'validation')
    z = this.getCurrentValidationData;
else
    ctrlMsgUtils.error('Ident:idguis:getNames1','getInputNames(h,DATATYPE)');
end

unames = pvget(z,'InputName');
