function [ctansw,cl2norm,cnlrgs,cnosgm, cdratio]=isnlarx(data,varargin)
%ISNLARX Tests the hypothesis that the model underlying the data is linear
%ARX vs nonlinear ARX alternative.
%
%   ISNLARX(DATA, ORDERS)
%
%   DATA: a time-domain IDDATA object.
%   ORDERS = [na nb nk], the orders and delays of an ARX model. With ny outputs
%      and nu inputs, na is ny-by-ny and nb, nk are ny-by-nu. See help on ARX.
%
%   ISNLARX returns an evaluation of whether nonlinearities have been
%   detected in DATA. The test only concerns whether an IDNLARX model with
%   the indicated orders is significantly better than a linear ARX model.
%   The properties of the tested IDNLARX model can be affected by
%   Property/Value pairs as in ISNLARX(DATA, ORDERS, Property1,Value1,....)
%   The property-value pairs used as same as those for NLARX function.
%
%   By default, all output channels in DATA are tested.
%   ISNLARX(DATA, ORDERS, KY) restricts the test to output channel KY.
%
%   You get access to the test quantities behind the  evaluation by
%   [NLHyp,NLvalue,NLRegs,NoiseSigma,DetectRatio] = ISNLARX(DATA, ORDERS,....)
%   The outputs are all ny-vectors, with entry ky containing the result
%   for output ky.
%   NLHyp: 1 if hypothesis of a linear model is rejected, 0 otherwise.
%   NLvalue: The estimated part of the Mean-Square-Error explained by the
%        nonlinearity. Compare with the Mean-square error NoiseSigma of the
%        unexplained output. NLvalue is zero if a linear model is not rejected.
%   NLRegs: The indices of the regressors that should enter nonlinearly in the
%        model. See IDPROPS NLARX.
%   NoiseSigma: The standard deviations of the innovations of DATA.
%   DetectRatio: The ratios of the test statistics and the detection threshold.
%       Small  (<0.5) or large (>2) DetectRatio signifies that the test is robust.
%       A value of DetectRatio close to 1 means that the test is on the edge of
%       detecting the nonlinearity.
%
%   See also nlarx, linapp, linearize, advice.
%

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2009/04/21 03:22:13 $

% idnlarx frontend for @treepartition/nltest
ni = nargin;
no = nargout;
error(nargchk(2, inf, ni,'struct'))
if ~(isa(data, 'iddata') || (~isempty(data) && isreal(data) && ndims(data)==2))
    ctrlMsgUtils.error('Ident:analysis:isnlarxInvalidInput')
end

data = idutils.utValidateData(data, [], 'time', true, 'isnlarx');

ky=[];
kyind=0;
nndef=0;

verbosethrsh=1/3;
% Syntax check
pvstart = 1;
%pvend=0;
nn = varargin{1};
if isscalar(nn)
    if nn<1 || rem(nn,1)
        ctrlMsgUtils.error('Ident:analysis:isnlarxSyntax')
    elseif size(data.OutputData,2)>1 % output dimension >1
        ky=nn;
        kyind=1;
        pvstart=2;
    elseif isempty(data.InputData) || size(data,'nu')==0 % an ar model
        nndef=1;
    else
        ctrlMsgUtils.error('Ident:analysis:isnlarxSyntax')
    end
else
    [ny, ncn] = size(nn);
    nu = (ncn-ny)/2;
    if isnonnegintmat(nn) && nu==round(nu)
        nndef=1;
        pvstart = 2;
    elseif ~ischar(nn)
        ctrlMsgUtils.error('Ident:analysis:isnlarxSyntax')
    end
end
if pvstart==2 &&ni>2
    ky=varargin{2};
    if ~ischar(ky)
        if max(size(ky))>1,
            ctrlMsgUtils.error('Ident:analysis:isnlarxSyntax')
        elseif kyind || ~isreal(ky) || ky<1 || ky>ny
            ctrlMsgUtils.error('Ident:analysis:isnlarxSyntax')
        else
            kyind=2;
            pvstart=3;
        end
    end
end

% Complex data cannot be used.
if iscell(get(data,'y'))||iscell(get(data,'u')),
    for ki=1:size(data,4)
        if ~isreal(get(getexp(data,ki),'y'))||~isreal(get(getexp(data,ki),'u')),
            ctrlMsgUtils.error('Ident:analysis:isnlarxComplexData')
        end
    end
else
    if ~isreal(get(data,'y'))||~isreal(get(data,'u'))
        ctrlMsgUtils.error('Ident:analysis:isnlarxComplexData')
    end
end
if ~nndef,
    ny=size(data,'Ny');
end
if ~kyind, ky=1:ny; end

if rem(ni-pvstart,2)
    ctrlMsgUtils.error('Ident:analysis:isnlarxSyntax')
end
if kyind,
    if kyind==1, pvlist=varargin(2:end);
    else pvlist={nn,varargin{3:ni-1}};
    end
else
    pvlist=varargin;
end
if nndef
    propstrs=2:2:length(pvlist)-1;
else
    propstrs=1:2:length(pvlist)-1; 
end
if ~iscellstr(pvlist(propstrs))
    ctrlMsgUtils.error('Ident:general:invalidPropertyName','isnlarx','isnlarx')
end
if nndef
    if length(pvlist)==1
        pvlist = {pvlist{1},'treepartition'};
    else
        pvlist = {pvlist{1},'treepartition',pvlist{2:end}};
    end
else
    pvlist = {pvlist{:},'Nonlinearity','treepartition'};
end

% Create IDNLARX object
sys = idnlarx(pvlist{:});
autofl=zeros(ny,1);
nlr = pvget(sys,'NonlinearRegressors');
if ~iscell(nlr) 
    nlr = {nlr}; 
end

for ki=1:ny
    if ischar(nlr{ki})
        if strcmp(nlr{ki},'search')
            autofl(ki)=1;
        end
    end
end
[ny, nu] = size(sys);

% Compute ARX prediction
warning off Ident:estimation:nonPersistentInput
marx = arx(data,[sys.na,sys.nb,sys.nk]);
warning on Ident:estimation:nonPersistentInput

ypl=predict(marx,data,1);
nex=size(data,4);
ypl=get(ypl,'y');
y0=get(data,'y');

if nex>1 % Multi-experiment data
    for ki=1:nex
        ypl{ki}=ypl{ki}-y0{ki};
    end
else
    ypl=ypl-y0;
end
% Compile the difference data object
data=iddata(ypl,get(data,'u'));

[data, msg] = datacheck(data, ny, nu);
error(msg)

[yvec, regmat, msg] = makeregmat(sys, data);
error(msg)

tansw=zeros(size(ky));
l2norm=zeros(size(ky));
nlregs=cell(size(ky));
nosgm=zeros(size(ky));
dcoef=zeros(size(ky));

for ki=ky
    if autofl(ki),
        [tansw(ki),l2norm(ki),nlregs{ki},nosgm(ki),cdratio(ki)]=nltest(sys.Nonlinearity(ki),...
            yvec{ki}, regmat{ki},1);
    else
        %       sys.Nonlinearity = setNonlinearRegressors(sys.Nonlinearity, pvget(sys, 'NonlinearRegressors'));
        [tansw(ki),l2norm(ki),nlregs{ki},nosgm(ki),cdratio(ki)]=nltest(sys.Nonlinearity(ki),...
            yvec{ki}, regmat{ki});
    end
end

% when called without arguments
algo = pvget(sys, 'Algorithm');
if ~no || strcmp(algo.Display, 'On') % present the results
    iname=sprintf('%s',inputname(1));
    if ny>1
        disp(' ')
        disp(['ISNLARX results for dataset ', iname]);
        disp(' ')
        for i=ky
            if ~tansw(i)
                disp(['Nonlinearity is not detected in channel (',num2str(i),').'])
                if cdratio(i)>verbosethrsh,
                    disp(['However, the test may be on the edge of detecting the nonlinearity.'])
                    disp(['Detection ratio: ',num2str(cdratio(i))])
                    if ~autofl(i)
                        disp('Searching for best nonlinear regressors may provide more reliable results.')
                    end
                end
            else
                disp(['Nonlinearity is detected in channel (',num2str(i),').']);
                disp(['Detection ratio: ',num2str(cdratio(i))])
                disp(['Estimated discrepancy of the linear model found: ',num2str(l2norm(i))]);
                disp(['Estimated noise standard deviation: ',num2str(nosgm(i))]);
                if autofl(i)
                    disp(['Corresponding NonlinearRegressors parameter: [',num2str(nlregs{i}),']'])
                end
            end
            disp('-')
        end
    else
        if ~tansw,
            disp(['Nonlinearity is not detected in data set ',iname])
            if dcoef>0.5,
                disp('However, the test may be on the edge of detecting the nonlinearity.')
                disp(['Detection ratio: ',num2str(cdratio)])
                if ~autofl
                    disp('Searching for best nonlinear regressors may provide more reliable results.')
                end
            end
        else
            disp(' ')
            disp(['Nonlinearity is detected in data set ',iname]);
            disp(['Detection ratio: ',num2str(cdratio)])
            disp(['Estimated discrepancy of the linear model found: ',num2str(l2norm)]);
            disp(['Estimated noise standard deviation: ',num2str(nosgm)]);
            if autofl
                disp(['Corresponding NonlinearRegressors parameter: [',num2str(nlregs{1}),']'])
            end
        end
    end
end
if no
    ctansw=tansw;
    cl2norm=l2norm;
    if length(nlregs)==1, nlregs=nlregs{1}; end
    cnlrgs=nlregs;
    cnosgm=nosgm;
end
% end of @iddata/isnlarx.m