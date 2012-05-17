function cout = bitsra(ain,kin)
% Embedded MATLAB Library function.
%
% BITSRA bitwise shift right arithmetic
%

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.13 $  $Date: 2009/12/07 20:41:43 $

% A shift is a shift; This function ignores fimath, 
% does not generate saturation and rounding logic. 

eml_assert((nargin > 1), 'Not enough input arguments.');
eml_prefer_const(kin);
cout = eml_fi_bitshift(ain, kin, 'bitsra');
