function thd=d2caux(thc,method,varargin)
%IDGREY/D2CAUX Help function to IDMODEL/D2C

%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $ $Date: 2008/10/02 18:47:38 $

if nargin < 1
    disp('Usage: MD = D2C(MC)')
    return
end
errm = struct('identifier','Ident:transformation:d2cSyntax',...
    'message','Incorrect property-value specification for the "d2c" command. Type "help idmodel/d2c" for more information.');
nv = length(varargin);
if fix(nv/2)~=nv/2
    error(errm);
end
%delays = 1;
%cov = 1;
for kk = 1:2:nv
    if ~ischar(varargin{kk})
        error(errm)
    elseif lower(varargin{kk}(1))=='c'
        if lower(varargin{kk+1}(1))=='n'
            %cov = 0;
            thc = pvset(thc,'CovarianceMatrix','None');
        end
    elseif lower(varargin{kk}(1))=='i'
        %{
        if varargin{kk+1}(1)==0
            delays = 0;
        end
        %}
    else
        error(errm)
    end
end

%{
if ischar(pvget(thc,'CovarianceMatrix'))
    cov = 0;
end
%}

Told = pvget(thc.idmodel,'Ts');
if Told==0
    ctrlMsgUtils.error('Ident:transformation:FirstArgDiscreteModel','d2c')
end
if strcmp(thc.CDmfile,'cd')
    if any(strcmp(pvget(thc,'DisturbanceModel'),{'None','Estimate'}))
        [a,b,c,d,k] = ssdata(thc);
        [ad,bd,cc,dd,kd] = idsample(a,b,c,d,k,Told,method,0);
        ut = pvget(thc,'Utility');
        ut.K = kd;
        thc = uset(thc,ut);
    end
    thd = pvset(thc,'Ts',0);
    thd = sethidmo(thd,'d2c',varargin{:}); % for the hidden models

else
    % to secure covariance info is not lost:
    thc = setcov(thc);
    thc = idss(thc);
    thd = d2c(thc,method,varargin{:});
end

