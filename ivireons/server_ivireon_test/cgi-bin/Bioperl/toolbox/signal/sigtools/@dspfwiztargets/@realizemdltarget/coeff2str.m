function str = coeff2str(hTar, coef, stage, H)
%COEFF2STR  Convert coefficient to string

%    This should be a private method

%    Copyright 1995-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:16 $

error(nargchk(4,4,nargin,'struct'));

coef = coef(stage);
fmt = ['% 22.18g'];

str = num2str(coef, fmt);
