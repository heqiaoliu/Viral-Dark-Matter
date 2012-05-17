function FPE1 = fpe(varargin)
%FPE Extracts the Final Prediction Error from a model.
%
%   FPE = FPE(Model);
%   FPE = FPE(Model1, Model2, ..., Modeln);
%
%   Model: any IDMODEL or IDNLMODEL.
%
%   FPE = Akaikes Final Prediction Error = V*(1+2*d/N), where V is the
%   loss function, d is the number of estimated parameters and N is the
%   number of estimation data. Note that d<<N is assumed.
%
%   See also AIC.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2009/03/09 19:15:03 $

FPE = [];
for kk = 1:length(varargin)
    if (~isa(varargin{kk}, 'idmodel') && ~isa(varargin{kk}, 'idnlmodel'))
        ctrlMsgUtils.error('Ident:analysis:modelInputsOnly','fpe')
    end
    try
        es = pvget(varargin{kk}, 'EstimationInfo');
        FPEk = es.FPE;
    catch
        FPEk = [];
    end
    FPE = [FPE(:)' FPEk];
end
if nargout
    FPE1 = FPE;
else
    disp(FPE);
end
