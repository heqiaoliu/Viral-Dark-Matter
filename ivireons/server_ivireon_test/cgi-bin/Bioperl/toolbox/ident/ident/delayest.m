function [nk,v] = delayest(z1,na,nb,nkmin,nkmax,maxtest)
%DELAYEST Estimates the delay (deadtime) directly from data.
%   NK = DELAYEST(DATA)
%
%   NK is the estimated delay in samples.
%   DATA is the input/output data as an IDDATA object.
%      Only single output data is supported.
%
%   NK = DELAYEST(DATA,NA,NB,NKMIN,NKMAX,MAXTEST) gives access to
%   NA: The number of denomininator coefficients in the models (Def 2)
%   NB: The number of numerator coefficients used in the tests. (Def 2)
%   NKMIN: A known lower bound for the delay. (Def 0). For data in closed
%        loop (output feedback present) use NKMIN = 1;
%   NKMAX: A known upper bound for the delays (Def NKMIN + 20)
%   NB, NKMIN and NKMAX should be row vectors of length = number of inputs.
%   If they are given as scalars, all inputs will be assigned the same
%   orders.
%   MAXTEST is the largest number of tests allowed (default 10,000). If the
%   suggested delay-span implies more test, an error results.
%
%   See also ARXSTRUC, SELSTRUC, IDDATA/IMPULSE.

%   L. Ljung 29-12-02
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.5.4.8 $  $Date: 2009/10/16 04:54:41 $

error(nargchk(1,6,nargin,'struct'))

if isa(z1,'frd') || isa(z1,'idfrd')
    z1 = iddata(idfrd(z1));
elseif ~isa(z1, 'iddata')
    ctrlMsgUtils.error('Ident:estimation:delayestCheck1')
end

[~,ny,nu] = size(z1);

if ny>1
    ctrlMsgUtils.error('Ident:estimation:delayestMultiOutput')
elseif nu==0
    ctrlMsgUtils.error('Ident:general:TimeSeriesData','delayest')
elseif any(cellfun(@(x)x==0,pvget(z1,'Ts')))
    % CT data cannot be handled
    ctrlMsgUtils.error('Ident:general:CTData','delayest')
end

if nargin<2
    na = 2;
end

if nargin<3
    nb = 2*ones(1,nu);
end

if nargin < 4
    nkmin = zeros(1,nu);
end

if nargin<5
    nkmax = nkmin+40;
end

nnk = (nkmin(1):nkmax(1))';
if nargin <6
    maxtest = 10000;
end

if length(nkmin)==1 && nu>1
    nkmin=nkmin*ones(1,nu);
end

if length(nkmin)>1 && length(nkmin)~=nu
    ctrlMsgUtils.error('Ident:estimation:delayestIncorrectNkminLen')
end

if any(nkmin<0)
    ctrlMsgUtils.error('Ident:estimation:delayestNegativeNkmin')
end

if length(nkmax)==1 && nu>1
    nkmax=nkmax*ones(1,nu);
end

if length(nkmax)>1 && length(nkmax)~=nu
    ctrlMsgUtils.error('Ident:estimation:delayestIncorrectNkmaxLen')
end

if length(nb)==1 && nu>1
    nb=nb*ones(1,nu);
end

if length(nb)>1 && length(nb)~=nu
    ctrlMsgUtils.error('Ident:estimation:delayestIncorrectNbLen')
end

nrtest = prod(nkmax-nkmin);

if nrtest>maxtest
    ctrlMsgUtils.error('Ident:estimation:delayestTooManyTests',nrtest,maxtest)
end

for ku=2:nu
    nk = (nkmin(ku):nkmax(ku))';
    nr = length(nk);
    [nrn] = size(nnk,1);
    nnk=[repmat(nnk,nr,1),sort(repmat(nk,nrn,1))];
end

lnn = size(nnk,1);
nn = [ones(lnn,1)*na repmat(nb,lnn,1) nnk];
v = arxstruc(z1,z1,nn);
nnc = selstruc(v,0);
nk = nnc(2+nu:end);
