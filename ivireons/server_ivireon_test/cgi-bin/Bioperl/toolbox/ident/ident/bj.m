function m = bj(varargin)
%BJ	Compute the prediction error estimate of a Box-Jenkins model.
%
%   M = BJ(Z,[nb nc nd nf nk])  or
%   M = BJ(Z,'nb',nb,'nc',nc,'nd',nd,'nf',nf,'nk',nk)
%
%   estimates a Box-Jenkins model represented by:
%   y(t) = [B(q)/F(q)] u(t-nk) +  [C(q)/D(q)]e(t)
%   where:
%       nb = order of B polynomial + 1 (row vector of Nu entries)
%       nf = order of F polynomial     (row vector of Nu entries)
%       nc = order of C polynomial     (scalar)
%       nd = order of D polynomial     (scalar)
%       nk = input delay (in number of samples, row vector of Nu entries)
%       (Nu = number of inputs)
%
%   The estimation may be performed using either time or frequency domain
%   data. The estimated model is delivered as an IDPOLY object. Type "help
%   idpoly" for more information on IDPOLY objects.
%
%   Output:
%       M : IDPOLY model containing estimated values for B, F, C and D
%       polynomials along with their covariances and structure information.
%
%   Inputs:
%       Z : The estimation data as an IDDATA or an IDFRD object. Use IDDATA
%       object for input-output signals (time or frequency domain). Use
%       IDFRD object for frequency response data. Type "help iddata"
%       and "help idfrd" for more information.
%
%       [nb nc nd nf nk]: Orders and delays of the Box-Jenkins model. When
%       specifying orders using property-value pairs (second syntax), all
%       the polynomial orders must be specified.
%
%   M = BJ(Z,Mi)
%   where Mi is an IDPOLY model of Box-Jenkins structure, updates its
%   parameters to fit data Z. The minimization is initialized at the
%   parameters given in Mi. Mi may be created using the IDPOLY constructor
%   or could be the result of a previous estimation.
%
%   M = BJ(Z,[nb,...,nk],'Property_1',Value_1, ...., 'Property_n',Value_n)
%   allows specification of the values of all properties associated with
%   the model and its estimation algorithm. Type "idprops idpoly" and
%   "idprops idmodel algorithm" for a list of applicable Property/Value
%   pairs.
%
%   Continuous-time models: This command cannot be used for estimating
%   continuous-time models. Some alternatives:
%   (1) Estimate a discrete-time BJ model first and then transform it into
%       continuous-time using the D2C command.
%   (2) Estimate a model of Output-Error structure using the OE command
%       using continuous-time frequency domain data (IDDATA or IDFRD with
%       property Ts = 0). Type "help oe" for more information.
%   Refer to documentation for other continuous-time estimation options.
%
%   See also ARX, ARMAX, IV4, N4SID, OE, PEM, IDPOLY, IDDATA, IDFRD, idmodel/D2C.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.13.4.11 $ $Date: 2009/12/22 18:53:35 $

error(nargchk(2,Inf,nargin,'struct'))

try
   [mdum,z] = pemdecod('bj',varargin{:},inputname(1));
catch E
   throw(E)
end
%err = 0;
z = setid(z);
if isa(mdum,'idpoly')
   if  pvget(mdum,'na')~=0
      ctrlMsgUtils.error('Ident:estimation:bjInvalidOrders')
   end
end
% $$$ fixp = pvget(mdum,'FixedParameter');
% $$$ if ~isempty(fixp)
% $$$    warning(sprintf(['To fix a parameter, first define a nominal model.',...
% $$$          '\nNote that mnemonic Parameter Names can be set by SETPNAME.']))
% $$$ end
try
   m = pem(z,mdum);
catch E
   if strcmp(E.identifier,'Ident:estimation:pemIncorrectOrders')
      ctrlMsgUtils.error('Ident:estimation:incorrectOrders','bj','bj')
   else
      throw(E)
   end
end

es = pvget(m,'EstimationInfo');
es.Method = 'BJ';
es.DataName = z.Name;
es.Status = 'Estimated model (PEM)';
m = pvset(m,'EstimationInfo',es);
m = timemark(m);
