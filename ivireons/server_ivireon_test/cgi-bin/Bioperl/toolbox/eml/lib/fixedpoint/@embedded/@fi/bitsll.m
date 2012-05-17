function cout = bitsll(ain,kin)
% Embedded MATLAB Library function.
%
% BITSLL bitwise shift left logical
%

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.11 $  $Date: 2009/12/07 20:41:42 $

% A shift is a shift; This function ignores fimath, 
% does not generate saturation and rounding logic. 

eml_assert((nargin > 1), 'Not enough input arguments.');
eml_prefer_const(kin);
cout = eml_fi_bitshift(ain, kin, 'bitsll');
