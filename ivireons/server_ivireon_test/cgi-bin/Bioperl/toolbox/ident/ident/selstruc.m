function [nn,Vmod] = selstruc(V,c)
%SELSTRUC Selects model structures according to various criteria.
%
%   NN = SELSTRUC(V)    NN = SELSTRUC(V,0) or   [NN,Vm] = SELSTRUC(V,c)
%
%   V: is a matrix containing information about different structures,
%   typically obtained as the output of ARXSTRUC or IVSTRUC.
%
%   c: selects the criterion:
%      c='PLOT' gives plots of the loss function. This is the default.
%      The plot shows the percentage of the output variance that is not
%      explained by the model, as a function of the number of parameters
%      used. Each value shows the best fit for that number of parameters.
%      The fit is defined as the sum of squared prediction errors for
%      the model, divided by the sum of squared outputs, expressed in percent.
%      By clicking in the plot you can examine which orders are of interest.
%      By clicking on SELECT, and then striking RETURN in the command window
%      the optimal model structure for your choice of number of parameters.
%      is returned.
%   NOTE: When the IDENT GUI is open, this plot option in SELSTRUC
%   is not available from the command line.
%
%   NN = SELSTRUC(V,0) returns the model structure with the best fit
%   to the validation data.
%
%   Automatic choices of structures are obtained by c='AIC', which gives
%   Akaike's information theoretic criterion, while c='MDL' gives
%   Rissanen's minimum description length criterion. If c is given a
%   numeric value, the structure is selected by minimization of
%   (1 + c*d/N)*Vd, where d is the number of estimated parameters,
%   Vd is the loss function of the corresponding model, and N is the
%   number of data.
%
%   NN: is returned as the chosen structure. The format is compatible
%   with the input format for ARX and IV4.
%   Vm: the first row of Vm contains the logarithms of the modified
%   criteria of fit. The remaining rows of Vm coincide with V.


%   L. Ljung 4-12-87,8-27-94
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.15.4.7 $  $Date: 2009/10/16 04:54:51 $

Vmod = [];
nn1 =[];
alpha = 0; %default, corresponding to c=0;
if nargin<2
    c = 'p'; %default
end
if (isa(c,'double') && c<0) || isempty(c)
    c = 'p';
end

[nl1,nm1] = size(V);
nu = floor((nl1-2)/2);
Nc = V(1,nm1);
if ischar(c)
    if lower(c(1)=='a')
        alpha = 2;
    elseif lower(c(1)=='m')
        alpha = log(Nc);
    end
elseif isa(c,'double') && isscalar(c) && isreal(c) && isfinite(c)
    alpha = c;
else
    ctrlMsgUtils.error('Ident:analysis:selstrucCheck1')
end

for kj=1:nm1-1
    Vmod(1,kj) = V(1,kj)*(1+(alpha/Nc)*sum(V(2:nu+2,kj)));
end
Vmod(2:nl1,1:nm1-1) = V(2:nl1,1:nm1-1);

if ischar(c) && any(lower(c(1))=='pl')
    X = getIdentGUIFigure;
    if ~isempty(X) && ~strcmp(get(X,'name'),'FAKE')
        ctrlMsgUtils.error('Ident:analysis:selstrucCheck2')
    end
    delete(findobj(allchild(0),'tag','sitb9'))
    if strcmp(get(X,'name'),'FAKE')
        close(X);
    end
    iduiarx('open',V);
    pstate = pause('on'); pause, pause(pstate);
    try
        nn = evalin('base','xxxnn');
        evalin('base','clear xxxnn')
    catch
        disp('No selection made.')
        nn = [];
    end
    iduiarx('close_NG')
    return
end

if isempty(nn1)
    [~,sel] = min(Vmod(1,1:nm1-1));
    nn1 = V(2:2+2*nu,sel)';
end

nn = nn1;
try
    Vmod(1,1:nm1-1) = log(Vmod(1,1:nm1-1));
end
