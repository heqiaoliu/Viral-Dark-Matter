function nlobj = initreset(nlobj)
%INITRESET resets the initialization of nonlinearity estimators
%
%  NL = INITRESET(NL0)
%
%  NL0: the original nonlinearity estimator object. See idprops idnlestimators.
%  NL:  the nonlinearity estimator object after reset.
%  
%  If NL0 is an array of nonlinearity estimator objects, so is NL.
%
%  INITRESET makes the parameters of NL non initialized.
%
%  For Multiple input nonlinearity estimators (see idprops idnlestimators),
%  INITRESET sets the input dimension of the nonlinearity estimator object
%  to undetermined so that there is no dimension compatibility problem when 
%  NL is inserted to an IDNLARX or IDNLHW model. 
%  Note that a nonlinearity estimator may have some restrictions when used 
%  in models (see idprops idnlestimators).
%
%  INITRESET is useful when a nonlinearity estimator object is extracted
%  from one model to be inserted to another model, as in the example:
%  
%    M2.Nonlinearity(2) = INITRESET(M1.Nonlinearity(1))
%
%  where M1 and M2 are IDNLARX model objects. Without INITRESET,The
%  dimension of M1.Nonlinearity(1) may be inconsistent with that of 
%  M2.Nonlinearity(2).

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2009/11/09 16:23:58 $

% Author(s): Qinghua Zhang

if isscalar(nlobj)
  if isinitialized(nlobj) % Adding this condition avoids resetting Parameters extended from a linear model (Oct 2009).
  nlobj = soinitreset(nlobj);
  end
else
  for ky=1:numel(nlobj)
    nlky = getcomp(nlobj,ky);
    if isinitialized(nlky) % Adding this condition avoids resetting Parameters extended from a linear model (Oct 2009).
      nlobj = setcomp(nlobj, ky, soinitreset(nlky));
    end
  end
end

% Oct2009
% FILE END