function display(this)
%DISPLAY  Display method for @dataset class.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:14:40 $

% Display inputname
InputName = inputname(1);
if isempty(InputName)
   InputName = 'ans';
end
fprintf('\n%s =\n\n',InputName)

if numel(this)>1
   % Array of data sets
   s = sprintf('%d-by-',size(this));
   fprintf('	hds.dataset: %s\n\n',s(1:end-4))
else
   % Single data set
   GridSize = [this.Grid_.Length];
   if isempty(GridSize)
      Ns = 0;
   else
      Ns = prod(GridSize);
   end
   % Display data
   disp(get(this))
   if length(GridSize)<=1
      disp(sprintf('Hierarchical data set with %d data points',Ns))
   else
      str = sprintf('%dx',GridSize);
      disp(sprintf('Hierarchical data set with %s grid of data points',str(1:end-1)))
   end
end