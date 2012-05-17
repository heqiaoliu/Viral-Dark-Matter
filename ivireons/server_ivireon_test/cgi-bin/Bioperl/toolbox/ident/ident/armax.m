function m = armax(varargin)
%ARMAX Compute the prediction error estimate of an ARMAX model.
%
%   M = ARMAX(Z,[na nb nc nk])  or
%   M = ARMAX(Z,'nb',nb,'nc',nc,'nd',nd,'nf',nf,'nk',nk)
%
%   estimates an ARMAX model represented by:
%   A(q) y(t) = B(q) u(t-nk) +  C(q) e(t)
%   where:
%       na = order of A polynomial     (scalar)
%       nb = order of B polynomial + 1 (row vector of Nu entries)
%       nc = order of C polynomial     (scalar)
%       nk = input delay (in number of samples, row vector of Nu entries)
%       (Nu = number of inputs)
%
%   The estimation may be performed using either time or frequency domain
%   data. The estimated model is delivered as an IDPOLY object. Type "help
%   idpoly" for more information on IDPOLY objects.
%
%   Output:
%       M : IDPOLY model containing estimated values for A, B, and C
%       polynomials along with their covariances and structure information.
%
%   Inputs:
%       Z : The estimation data as an IDDATA or an IDFRD object. Use IDDATA
%       object for input-output signals (time or frequency domain). Use
%       IDFRD object for frequency response data. Type "help iddata"
%       and "help idfrd" for more information.
%
%       [na nb nc nk]: Orders and delays of the ARMAX model. When
%       specifying orders using property-value pairs (second syntax), all
%       the polynomial orders must be specified.
%
%   M = ARMAX(Z,Mi)
%   where Mi is an IDPOLY model of ARMAX structure, updates its
%   parameters to fit data Z. The minimization is initialized at the
%   parameters given in Mi. Mi may be created using the IDPOLY constructor
%   or could be the result of a previous estimation.
%
%   M = ARMAX(Z,[na,...,nk],'Property_1',Value_1, ...., 'Property_n',Value_n)
%   allows specification of the values of all properties associated with
%   the model and its estimation algorithm. Type "idprops idpoly" and
%   "idprops idmodel algorithm" for a list of applicable Property/Value
%   pairs.
%
%   Continuous-time models: This command cannot be used for estimating
%   continuous-time models. Some alternatives:
%   (1) Use D2C to convert a discrete-time model into a continuous-time
%       one. This transformation need not preserve the model structure.
%   (2) Estimate a model of Output-Error structure using the OE command
%       using continuous-time frequency domain data (IDDATA or IDFRD with
%       property Ts = 0). Type "help oe" for more information.
%   Refer to documentation for other continuous-time estimation options.
%
%   See also ARX, BJ, IV4, N4SID, OE, PEM, IDPOLY, IDDATA, IDFRD, idmodel/D2C.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.18.4.11 $ $Date: 2009/12/22 18:53:32 $

error(nargchk(2,Inf,nargin,'struct'))

try
   [mdum,z] = pemdecod('armax',varargin{:},inputname(1));
catch E
   throw(E)
end

err = 0;
z = setid(z);

if isa(mdum,'idpoly')
   nd = pvget(mdum,'nd');
   nf = pvget(mdum,'nf');
   if sum([nd nf])~=0
      err = 1;
   end
else
   err = 1;
end
if err
   ctrlMsgUtils.error('Ident:estimation:invalidARMAXStructure')
end
% $$$ fixp = pvget(mdum,'FixedParameter');
% $$$ if ~isempty(fixp)
% $$$    warning(sprintf(['To fix a parameter, first define a nominal model.',...
% $$$          '\nNote that mnemonic Parameter Names can be set by SETPNAME.']))
% $$$ end
try
   m = pem(z,mdum);
catch E
   throw(E)
end

es = pvget(m,'EstimationInfo');
es.Method = 'ARMAX';
es.DataName = z.Name;
es.Status = 'Estimated model (PEM)';
m = pvset(m,'EstimationInfo',es);
m = timemark(m);
