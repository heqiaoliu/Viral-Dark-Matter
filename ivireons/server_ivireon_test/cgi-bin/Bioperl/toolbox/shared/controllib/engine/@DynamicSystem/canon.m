function [sys,varargout] = canon(sys,Type,condt)
%CANON  Canonical state-space realizations.
%
%   CSYS = CANON(SYS,TYPE) computes a canonical state-space 
%   realization CSYS for the LTI model SYS.  The string TYPE
%   selects the type of realization:
%     'modal'       Modal decomposition where the state matrix A 
%                   is block diagonal, each block corresponding 
%                   to a cluster of nearby modes.
%     'companion'   Companion form where the characteristic
%                   polynomial appears in the rightmost column.
%
%   [CSYS,T] = CANON(SYS,TYPE) also returns the state transformation 
%   matrix T relating the canonical state vector z to the original 
%   state vector x by z = Tx.  This syntax is only meaningful when 
%   SYS is a state-space model.
%
%   CSYS = CANON(SYS,'modal',CONDT) specifies an upper bound CONDT on
%   the condition number of the block-diagonalizing transformation T. 
%   The default value is 1/SQRT(EPS).  Increase CONDT to reduce the
%   size of the eigenvalue clusters (setting CONDT=Inf amounts to 
%   diagonalizing A).
%
%   The modal form is useful for determining the relative contribution
%   of each system mode.  The companion form is ill-conditioned and 
%   should be avoided if possible.
%
%   See also SS, POLE, SS2SS, CTRB, CTRBF.

%   Clay M. Thompson  7-3-90
%   Revised: P. Gahinet  6-27-96
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:32 $
no = nargout-1;
ni = nargin;
if ni<2,   % No type specified, assume modal 
   Type = 'modal';
end
if ni<3
   condt = 1e8;
else 
   condt = min(condt,realmax);
end

% Validation
if ~ischar(Type),
   ctrlMsgUtils.error('Control:transformation:canon1')
elseif ndims(sys)>2,
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','canon')
elseif no>0 && ~isa(sys,'StateSpaceModel')
   % Set T=[] for non-empty state-space models
   no = 0;  varargout = {[]};
end

% Convert to numerical state space
try
   sys = ss(sys);
catch%#ok<CTCH>
   ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass','canon',class(sys))
end

% Call state-space implementation
try
   [sys,varargout{1:no}] = canon_(sys,Type,condt);
catch E
   throw(E)
end
