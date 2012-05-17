function r = digits(d)
%DIGITS Set variable precision digits.
%   Digits determines the accuracy of variable precision numeric computations.
%   DIGITS, by itself, displays the current setting of Digits.
%   DIGITS(D) sets Digits to D for subsequent calculations. D is an 
%      integer, or a string or sym representing an integer.
%   D = DIGITS returns the current setting of Digits. D is an integer.
%
%   See also VPA.

%   Copyright 1993-2010 The MathWorks, Inc. 

eng = symengine;
if strcmp(eng.kind,'maple')
  if nargin == 1
    mapleengine('digits',d);
  elseif nargout == 1
    r = mapleengine('digits');
  else
    mapleengine('digits');
  end
else
  if nargin == 1
      if isnumeric(d), d = int2str(d); end
      mupadmex(sprintf('DIGITS := %s:', d));
      mupadmex(d,15);
  elseif nargout == 1
    r = eval(mupadmex('DIGITS',0));
  else
    disp(' ');
    disp(sprintf('Digits = %s',mupadmex('DIGITS',0)))
    disp(' ');
  end
end
