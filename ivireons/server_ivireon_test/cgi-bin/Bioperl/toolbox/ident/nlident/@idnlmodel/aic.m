function AIC1 = aic(varargin)
%AIC Computes Akaike's Information Criterion (AIC) for one or more models.
%
%   AIC = AIC(Model);
%   AIC = AIC(Model1, Model2, ..., Modeln);
%
%   Model: any IDMODEL or IDNLMODEL.
%
%   AIC = Akaikes Information Criterion log(V) + 2d/N, where V is the loss
%   function, d is the number of estimated parameters and N is the number
%   of estimation data.
%
%   See also FPE.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2008/10/02 18:54:28 $

AIC = [];
for kk = 1:length(varargin)
    if (~isa(varargin{kk}, 'idmodel') && ~isa(varargin{kk}, 'idnlmodel'))
        ctrlMsgUtils.error('Ident:analysis:modelInputsOnly','aic')
    end
    try
        AICk = 1;
        es = pvget(varargin{kk}, 'EstimationInfo');
        FPE = es.FPE;
        V = es.LossFcn;
    catch
        AICk = [];
    end
    if ~isempty(AICk)
        %Nnpar = ((FPE/V)-1)/((FPE/V)+1);
        %AICk = log(V) + 2*Nnpar;
        Nnpar = FPE/V-1; AICk = log(V)+Nnpar;
    end
    AIC = [AIC(:)' AICk];
end
if nargout
    AIC1 = AIC;
else
    disp(AIC);
end