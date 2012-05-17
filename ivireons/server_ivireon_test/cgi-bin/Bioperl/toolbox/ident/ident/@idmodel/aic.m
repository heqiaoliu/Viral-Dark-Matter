function AIC1 = aic(varargin)
%AIC Computes Akaike's Information Criterion(AIC) from a model
%   AIC = AIC(Model), AIC(Model1,Model2,...,Modeln)
%
%   Model = Any IDMODEL or IDNLMODEL
%
%   AIC = Akaikes Information Criterion log(V) + 2d/N
%   where V is the loss function, d is the number of estimated parameters
%   and N is the number of estimation data.
%
%   See also FPE.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.6.4.6 $  $Date: 2008/10/02 18:47:50 $

AIC=[];
for kk = 1:length(varargin)
    model = varargin{kk};
    if ~isa(model,'idmodel')&&~isa(model,'idnlmodel')
        ctrlMsgUtils.error('Ident:analysis:modelInputsOnly','aic')
    end
    try
        AICk =1;
        es = pvget(model,'EstimationInfo');
        FPE = es.FPE;
        N = es.DataLength;
        V = es.LossFcn;
    catch
        AICk = [];
    end
    if ~isempty(AICk)
        %Nnpar = ((FPE/V)-1)/((FPE/V)+1);
        %AICk = log(V)+2*Nnpar;
        Nnpar = FPE/V-1; AICk = log(V)+Nnpar;
    end
    AIC = [AIC,AICk];
end
if nargout
    AIC1 = AIC;
else
    disp(' ')
    disp(AIC)
end

