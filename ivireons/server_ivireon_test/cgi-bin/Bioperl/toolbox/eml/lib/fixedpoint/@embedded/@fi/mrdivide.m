function c = mrdivide(a,b)
%/ Fixed point eML library function for mrdivide
%
%    Matrix division is not allowed, but division by a scalar is.  For example:
%      fi(magic(3)) / fi(2)
%    is allowed, but
%      fi(magic(3)) / fi(randn(3))
%    is not allowed.
%
%    See also RDIVIDE.

%   Thomas A. Bryan and Becky Bryan, 30 December 2008
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/11/13 04:16:46 $
%#eml

eml_allow_mx_inputs;

eml_assert(isscalar(b),'For fi objects, B must be a scalar in A/B.');

% A/B is the same as A./B when B is a scalar.
c = rdivide(a,b);

    
    
