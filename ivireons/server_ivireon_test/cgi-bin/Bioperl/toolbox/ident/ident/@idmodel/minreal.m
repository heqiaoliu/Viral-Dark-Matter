function m = minreal(m,tol)
%IDMODEL/MINREAL  Minimal realization.
%
%   MMOD = MINREAL(MODEL) produces, for a given IDSS model MODEL, an
%   equivalent model MMOD where all uncontrollable or unobservable 
%   modes have been removed.
%
%   MSYS = MINREAL(SYS,TOL) further specifies the tolerance TOL
%   used for state dynamics elimination. 
%   The default value is TOL=SQRT(EPS) and increasing this tolerance
%   forces additional cancellations.
%  
%   MINREAL requires Control System Toolbox.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.7.4.4 $  $Date: 2008/10/02 18:48:15 $

if ~iscstbinstalled
    ctrlMsgUtils.error('Ident:general:cstbRequired','minreal')
end

if nargin ==1
   tol = sqrt(eps);
end

if ~isa(m,'idss')
  ctrlMsgUtils.warning('Ident:transformation:minreal1')
end

m = idss(m);
m = minreal(m,tol);
