function m = oe(varargin)
%OE	Compute the prediction error estimate of an Output Error model.
%
%   M = OE(Z,[nb nf nk]) or 
%   M = OE(Z,'nb',nb,'nf',nf,'nk',nk)
%
%   estimates an Output Error model represented by: 
%   y(t) = [B(q)/F(q)] u(t-nk) +  e(t)
%   where: 
%       nb = order of B polynomial + 1 (row vector of Nu entries)
%       nf = order of F polynomial     (row vector of Nu entries)
%       nk = input delay (in number of samples, row vector of Nu entries)
%       (Nu = number of inputs)
%
%   The estimation may be performed using either time or frequency domain
%   data. The estimated model is delivered as an IDPOLY object. Type "help
%   idpoly" for more information on IDPOLY objects.
%   
%   Output:
%       M : IDPOLY model containing estimated values for B and F
%       polynomials along with their covariances and structure information.
%
%   Inputs:
%       Z : The estimation data as an IDDATA or an IDFRD object. Use IDDATA
%       object for input-output signals (time or frequency domain). Use
%       IDFRD object for frequency response data. Type "help iddata"
%       and "help idfrd" for more information.
%
%       [nb nf nk]: Orders and delays of the Output Error model. When
%       specifying orders using property-value pairs (second syntax), both
%       the polynomial orders ('nb', 'nf') must be specified.
%
%   M = OE(Z,Mi)
%   where Mi is an IDPOLY model of Output Error structure, updates its
%   parameters to fit data Z. The minimization is initialized at the
%   parameters given in Mi. Mi may be created using the IDPOLY constructor
%   or could be the result of a previous estimation.
%
%   M = OE(Z,[nb,nf,nk],'Property_1',Value_1, ...., 'Property_n',Value_n)
%   allows specification of the values of all properties associated with
%   the model and its estimation algorithm. Type "idprops idpoly" and
%   "idprops idmodel algorithm" for a list of applicable Property/Value
%   pairs. 
%   
%   Continuous-time models: Models with Ts=0 can be estimated directly when
%   using continuous-time frequency domain data. Then 'nk' should be
%   omitted from orders.
%   Example: Fit continuous-time transfer function to frequency response
%   1. Generate data: 
%       SYS = tf([1 3],[1 2 1 1]); %TF requires Control System Toolbox
%       G = idfrd(SYS); % G is continuous-time frequency response data
%   2. Estimate an OE model to fit the data
%       M = oe(G, [2 3]); %use syntax OE(DATA, [nb, nf])
%       bode(G, M) % compare data to model
%
%   See also IDPROC models that represent continuous-time transfer
%   functions of low orders. IDPROC models may be estimated using either
%   time or frequency domain data. If you have a discrete-time IDPOLY
%   model, you can transform it into a continuous-time model using D2C
%   command. 
%
%   See also ARX, ARMAX, IV4, N4SID, BJ, PEM, IDPOLY, IDDATA, IDFRD, idmodel/D2C,
%   IDPROC.

%   Lennart Ljung 10-10-86
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.19.4.10 $  $Date: 2009/12/22 18:53:40 $

error(nargchk(2,Inf,nargin,'struct'))

try
    [mdum,z] = pemdecod('oe',varargin{:},inputname(1));
catch E
    throw(E)
end

err = 0;
z = setid(z);
if isa(mdum,'idpoly')
    nd = pvget(mdum,'nd');
    nc = pvget(mdum,'nc');
    na = pvget(mdum,'na');

    if sum([nd na nc])~=0
        err = 1;
    end
else
    err = 1;
end

if err
    ctrlMsgUtils.error('Ident:estimation:oeInvalidOrders')
end
% $$$ fixp = pvget(mdum,'FixedParameter'); $$$ if ~isempty(fixp) $$$
% warning(sprintf(['To fix a parameter, first define a nominal
% model.',...  $$$ '\nNote that mnemonic Parameter Names can be set by
% SETPNAME.']))  $$$ end

try
    m = pem(z,mdum);
catch E
    if strcmp(E.identifier,'Ident:estimation:pemIncorrectOrders')
        ctrlMsgUtils.error('Ident:estimation:incorrectOrders','oe','oe')
    else
        throw(E)
    end
end

es = pvget(m,'EstimationInfo');
es.Method = 'OE';
es.DataName = z.Name;
es.Status = 'Estimated model (PEM)';
m = pvset(m,'EstimationInfo',es);
m = timemark(m);
