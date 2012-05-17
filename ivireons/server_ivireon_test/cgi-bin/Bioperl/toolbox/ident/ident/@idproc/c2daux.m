function [thd,G]=c2daux(thc,T,method)
%IDPROC/C2DAUX  Converts a continuous time model to discrete time.
%
%   SYSD = C2D(SYSC,Ts,METHOD)
%
%   SYSC: The continuous time model, a IDPROC object
%
%   Ts: The sampling interval
%
%   METHOD: 'Zoh' (default) or 'Foh', corresponding to the
%      assumptions that the input is Zero-order-hold (piecewise
%      constant) or First-order-hold (piecewise linear)
%
%    SYSD will be returned as an IDGREY object with the MATLAB file's own
%    sampling. 

%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.6.4.8 $ $Date: 2010/03/22 03:48:51 $

error(nargchk(2,Inf,nargin,'struct'))
G = [];
if nargin < 3
    try
        es = pvget(thc,'EstimationInfo');
        method = es.DataInterSample;
    catch
        method = 'zoh';
    end
end
Td = pvget(thc,'Td');Td = Td.value;
nu = size(thc,'nu');
if isnan(Td),Td = 0;end

inpd = floor(Td/T);
newtd = Td-inpd*T; newtd(newtd>T) = 0;
thc = pvset(thc,'Td',newtd);
thc = idgrey(thc);
filea = pvget(thc,'FileArgument');

if ~iscell(method), method = {method}; end
if length(method)<nu
    method = repmat(method,1,nu);
end

filea{2} = method;
thc = pvset(thc,'FileArgument',filea);

if nargout == 2
    [dum,G]= c2daux(idss(thc),T,method{1});
end
lamscale=1/T;
thd = pvset(thc,'Ts',T,'InputDelay',inpd,'NoiseVariance',pvget(thc,'NoiseVariance')*lamscale);
thd = sethidmo(thd,'c2d',T,method);

