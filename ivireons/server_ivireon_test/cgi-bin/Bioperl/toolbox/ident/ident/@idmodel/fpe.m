function FPE1 = fpe(varargin)
%FPE Extracts the Final Prediction Error from a model.
%   FPE = FPE(Model)
%
%   Model = Any IDMODEL or IDNLMODEL
%
%   FPE = Akaikes Final Prediction Error = V*(1+2*d/N)
%   where V is the loss function, d is the number of estimated parameters
%   and N is the number of estimation data samples. Note that d<<N is
%   assumed. 
%
%   See also AIC.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.6.4.7 $  $Date: 2009/03/09 19:13:38 $

FPE=[];
for kk = 1:length(varargin)
    model = varargin{kk};
    if ~isa(model,'idmodel')&&~isa(model,'idnlmodel')
        ctrlMsgUtils.error('Ident:analysis:modelInputsOnly','fpe')
    end
    try
        FPEk = model.EstimationInfo.FPE;
    catch
        FPEk = [];
    end
    FPE = [FPE,FPEk];
end
if nargout
    FPE1 = FPE;
else
    disp(FPE)
end

