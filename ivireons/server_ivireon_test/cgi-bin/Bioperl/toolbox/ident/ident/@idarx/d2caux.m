function thd=d2caux(thc,method,varargin)
%IDARX/D2CAUX Help function to IDMODEL/D2C

%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.4.2.7 $ $Date: 2008/10/02 18:46:28 $

if nargin < 1
    disp('Usage: SYSD = D2C(SYSC)')
    disp('       SYSD = D2C(SYSC,METHOD)')
    disp('       METHOD is one of ''Zoh'' or ''Foh''')
    return
end
if ~iscstbinstalled
    ctrlMsgUtils.error('Ident:general:idarxCSTBRequired')
end
errm = struct('identifier','Ident:transformation:d2cSyntax',...
    'message','Incorrect property-value specification for the "d2c" command. Type "help idmodel/d2c" for more information.');

nv = length(varargin);
if fix(nv/2)~=nv/2
    error(errm);
end
delays = 1;
cov = 1;
for kk = 1:2:nv
    if ~ischar(varargin{kk})
        error(errm)
    elseif lower(varargin{kk}(1))=='c'
        if lower(varargin{kk+1}(1))=='n'
            cov = 0;
        end
    elseif lower(varargin{kk}(1))=='i'
        if varargin{kk+1}(1)==0
            delays = 0;
        end
    else
        error(errm)
    end
end
if ischar(pvget(thc,'CovarianceMatrix'))
    cov = 0;
end
if cov==0
    thc = pvset(thc,'CovarianceMatrix','None');
end
Told=pvget(thc.idmodel,'Ts');
if Told==0,
    ctrlMsgUtils.error('Ident:transformation:FirstArgDiscreteModel','d2c')
end

[ny,nu]=size(thc);
p = pvget(thc.idmodel,'ParameterVector');
nkflag = 0;
if delays
    nka = thc.nk;
    nk = min(nka);
    if any(nk>1)
        nknew = nk>=1;
        adjnk = nk-nknew;
        thc = pvset(thc,'nk',nka-ones(ny,1)*adjnk);
        nkflag = 1;
    end
end

thc = setcov(thc); % so that covinfo is not lost in the transformation. No loss of time
% is CovarianceMatrix = 'None',
thc = minreal(idss(thc));
thd = d2caux(thc,method,varargin{:});
if any(any(isinf(pvget(thd,'A'))'))
    ctrlMsgUtils.error('Ident:transformation:idarxD2CFailed',method)
end
if nkflag
    thd = pvset(thd,'InputDelay',adjnk*Told);
end
