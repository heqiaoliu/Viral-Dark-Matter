function str = coeff2str(NL, coef, stage)
%COEFF2STR  Convert coefficient to string

%    This should be a private method
%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:31 $

error(nargchk(3,3,nargin,'struct'));

if stage <= length(coef)
    coef1 = coef(stage);
else
    coef1 = 0;
end
fmt = ['% 22.18g'];

str = num2str(coef1, fmt);
