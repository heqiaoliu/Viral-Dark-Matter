function result = subsref(sys,Struct)
%SUBSREF  Subsref method for IDFRD models
%   The following reference operations can be applied to an FRD model H:
%
%      H(Outputs,Inputs)     select subsets of I/O channels.
%      H.Fieldname           equivalent to GET(MOD,'Fieldname')
%   These expressions can be followed by any valid subscripted
%   reference of the result, as in H(1,[2 3]).inputname or
%   squeeze(H.cov(25,2,3,:,:))
%
%   The channel reference can be made by numbers or channel names:
%     H('velocity',{'power','temperature'})
%   For single output systems H(ku) selects the input channels ku
%   while for single input systems H(ky) selcets the output
%   channels ky.
%
%   H('measured') selects just the measured input channels and
%       ignores the noise inputs, that is only ResponseData and
%       CovarianceData are kept.
%
%   H('noise') extracts SpectrumData and NoiseCovariance.
%

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.11.2.8 $  $Date: 2009/03/09 19:13:31 $

StrucL = length(Struct);

switch Struct(1).type
    case '.'
        tmpval = get(sys,Struct(1).subs);
        if StrucL==1
            result = tmpval;
        else
            result = subsref(tmpval,Struct(2:end));
        end
    case '()'

        try
            if StrucL==1,
                result = indexref(sys,Struct(1).subs);
            else
                result = subsref(indexref(sys,Struct(1).subs),Struct(2:end));
            end
        catch E
            throw(E)
        end


    otherwise
        ctrlMsgUtils.error('Ident:general:unSupportedSubsrefType',Struct(1).type,'IDFRD')
end

%--------------------------------------------------------------------------
function sys = indexref(sys,index)
resp=sys.ResponseData;
covd=sys.CovarianceData;
spect=sys.SpectrumData;
ncov = sys.NoiseCovariance;
[ny,nu,N]=size(sys);

if length(index)>2 && strcmp(index{3},'s')
    silent = 1;
else
    silent = 0;
end
if isnumeric(index{1}) && length(index{1})>max(ny,nu)
    ctrlMsgUtils.error('Ident:idfrd:subsrefCheck1')
end
if length(index)==1
    if any(strcmpi(index{1}(1),{'n','m'})) %%LL%% if channel name ..
        index{2}=index{1};
        index{1}=':';
    elseif ny==1
        index{2}=index{1};
        index{1}=1;
    elseif any(nu==[0 1]) % Here index > nu should be caught
        index{2}=':';
    end
end
if isnumeric(index{1}) && length(index{1})>ny
    ctrlMsgUtils.error('Ident:idfrd:subsrefCheck2')
end
[yind,errflagy] = indmatch(index{1},pvget(sys,'OutputName'),ny,'Output');
if ~silent
    if ~isempty(errflagy.message), error(errflagy), end
else
    if ~isempty(errflagy.message)
        sys =[];
        return
    end
end

if nu == 0
    uind = [];
    flagmea = 0;
    %{
    if strcmpi(index{2}(1),'a')
        flagall = 1;
    else
        flagall = 0;
    end
    %}
else
    if  isnumeric(index{2}) && length(index{2})>nu
        ctrlMsgUtils.error('Ident:idfrd:subsrefCheck3')
    end
    [uind,errflagu,flagmea] = indmatch(index{2},pvget(sys,'InputName'),...
        nu,'Input',0);
    if ~silent
        if ~isempty(errflagu.message), error(errflagu), end
    else
        if ~isempty(errflagu.message)
            sys =[];
            return
        end
    end
end
if isempty(uind)
    sys = tsflag(sys,'set');
end

nk=sys.InputDelay;
if ~isempty(nk),nk=nk(uind);end
if flagmea
    spect1=zeros(0,0,N);
    ncov1 = spect1;
else
    if isempty(spect)
        spect1 = [];
    else

        spect1 = spect(yind,yind,:);
    end
    if isempty(ncov)
        ncov1=[];
    else
        ncov1 = ncov(yind,yind,:);
    end

end
if isempty(resp)
    resp1 = [];
else
    resp1 = resp(yind,uind,:);
end
if isempty(covd)
    covd1=[];
else
    covd1 = covd(yind,uind,:,:,:);
end

sys = pvset(sys,'ResponseData',resp1,'CovarianceData',covd1,...
    'SpectrumData',spect1,'NoiseCovariance',ncov1,'InputDelay',nk,...
    'InputName',sys.InputName(uind),'InputUnit',sys.InputUnit(uind),...
    'OutputName',sys.OutputName(yind),'OutputUnit',sys.OutputUnit(yind)...
    );
