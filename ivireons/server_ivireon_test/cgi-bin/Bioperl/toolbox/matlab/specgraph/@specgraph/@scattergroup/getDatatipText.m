function str = getDatatipText(this,dataCursor)

% Copyright 2004 The MathWorks, Inc.

pos = get(dataCursor,'Position');
is3D = ~isempty(get(this,'zdata'));
N_DIGITS = 4;
if is3D
   str = {['X = ' num2str(pos(1),N_DIGITS)], ...
          ['Y = ' num2str(pos(2),N_DIGITS)], ...
          ['Z = ' num2str(pos(3),N_DIGITS)]};
else
   str = {['X = ' num2str(pos(1),N_DIGITS)], ...
          ['Y = ' num2str(pos(2),N_DIGITS)]};
end