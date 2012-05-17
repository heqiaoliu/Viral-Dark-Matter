function dydx = utEvalStateJacobian(x,par,type)
%UTEVALSTATEJACOBIAN Gateway function for jacobian computation (dy/dx).
%
%  dydx = utEvalStateJacobian(x,par,type)
%   Output:
%       dydx: derivative of output w.r.t regressors (x).
%   Inputs:
%       x: regressors
%       par: parameter struct (may contain additional info, such as NumberOfUnits)
%       type: class name of nonlinearity estimator for which jacobian is to
%       be computed.
%
%  This function is called from S function blocks during linearization, as
%  a mexCallMATLAB call.
%
%  See also idnlfun/setpar, idnlfun/getJacobian, utEvalCustomReg.

%   Written by: Rajiv Singh
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:52:09 $

SetParFlag = true;
try
    switch lower(type)
        case 'treepartition'
            nlobj = treepartition;
        case 'linear'
            nlobj = linear;
        case 'wavenet'
            nlobj = wavenet;
        case 'sigmoidnet'
            nlobj = sigmoidnet;
        case 'pwlinear'
            nlobj = pwlinear;
        case {'neuralnet','customnet'}
            nlobj = par; %par itself is the object
            SetParFlag = false;
        case 'poly1d'
            nlobj = poly1d;
        case 'saturation'
            nlobj = saturation;
        case 'deadzone'
            nlobj = deadzone;
        case 'unitgain'
            nlobj = unitgain;
        otherwise
            ctrlMsgUtils.error('Ident:utility:JacobianCalculationFailure1',upper(type))
    end
    
    if SetParFlag
        nlobj = setpar(nlobj,par);
    end
    [dum1,dum2,dydx] = getJacobian(nlobj,x,false);
catch
    ctrlMsgUtils.warning('Ident:utility:JacobianCalculationFailure2')
    dydx = zeros(size(x));
end
