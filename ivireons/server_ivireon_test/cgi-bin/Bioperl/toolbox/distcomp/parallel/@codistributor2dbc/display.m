function display(D)
%DISPLAY Display codistributor
%
%   See also DISPLAY, CODISTRIBUTOR.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:00:05 $

if ~isequal(get(0,'FormatSpacing'),'compact'), fprintf('\n'), end
fprintf('%s =\n',inputname(1))
disp(D);
if ~isequal(get(0,'FormatSpacing'),'compact'), fprintf('\n'), end

end % End of display.
