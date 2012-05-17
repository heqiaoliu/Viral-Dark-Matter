function display(this)
%DISPLAY Display method for @PlotOptions

%  Author(s): C. Buhr
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:50 $

% Display inputname
InputName = inputname(1);
if isempty(InputName)
   InputName = 'ans';
end
fprintf('\n%s =\n\n',InputName)

if numel(this)>1
   % Array of Plot Options
   s = sprintf('%d-by-',size(this));
   fprintf('	%s: %s\n\n',class(this),s(1:end-4))
else
   % Single Plot Options
   % Display data
   disp(get(this))
end
