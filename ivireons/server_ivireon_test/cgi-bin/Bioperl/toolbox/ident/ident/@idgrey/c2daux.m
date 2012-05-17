function [thd,G]=c2daux(thc,T,method)
%IDGREY/C2D  Converts a continuous time model to discrete time.
%
%   SYSD = C2D(SYSC,Ts,METHOD)
%
%   SYSC: The continuous time model, an IDGREY object
%
%   Ts: The sampling interval
%
%   METHOD: 'Zoh' (default) or 'Foh', corresponding to the
%      assumptions that the input is Zero-order-hold (piecewise
%      constant) or First-order-hold (piecewuse linear)
%
%   If the property CDmfile='cd' SYSD will be returned as a IDGREY
%   object with the mfile's own sampling.
%
%   Otherwise the discrete time model SYSD is an IDSS object with
%   'SSParameterization' = 'Free'. Note that the covariance matrix
%   is not translated in that case.
%

%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.8.4.9 $ $Date: 2009/03/09 19:13:33 $

error(nargchk(2,Inf,nargin,'struct'))
G = [];
if nargin < 3
    method = 'Zoh';
end

Told=pvget(thc.idmodel,'Ts');
if Told>0
    ctrlMsgUtils.error('Ident:transformation:FirstArgContinuousModel','c2d')
end

if T<=0
    ctrlMsgUtils.error('Ident:transformation:c2dNonPositiveTs')
end

if strcmp(thc.CDmfile,'cd')
    MfName = pvget(thc,'MfileName');
    
    inpd = pvget(thc,'InputDelay');
    if any(inpd)
        if strcmp(thc.MfileName,'procmod') % then the input delays will
            % be fixed automatically
            thc = pvset(thc,'InputDelay',zeros(size(inpd)));
        else
            if ~isempty(inpd) && (any(inpd/T~=fix(inpd/T)))
                ctrlMsgUtils.error('Ident:transformation:c2dIdgreyCheck1', MfName)
            end
            thc = pvset(thc,'InputDelay',inpd/T);
        end
    end
    if any(strcmp(pvget(thc,'DisturbanceModel'),{'None','Estimate'}))
        [a,b,c,d,k] = ssdata(thc);
        [ad,bd,cc,dd,kd,dum,G] = idsample(a,b,c,d,k,T,method);
        ut = pvget(thc,'Utility');
        ut.K = kd;
        thc = uset(thc,ut);
    elseif nargout==2
        thc1 = pvset(thc,'InputDelay',inpd);
        [dum,G] = c2daux(idss(thc1),T,method);
    end
    thd = pvset(thc,'Ts',T);
    thd = sethidmo(thd,'c2d',T,method);
else
    % to secure covariance info is not lost:
    cv = pvget(thc,'CovarianceMatrix');
    if ~ischar(cv) && ~isempty(cv)
        thc = setcov(thc);
    end
    thd = idss(thc);
    [thd,G] = c2daux(thd,T,method);
end

