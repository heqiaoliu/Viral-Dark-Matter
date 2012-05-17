function display(this)
% display the contents of the custom regressor

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:18:16 $

% Author(s): Qinghua Zhang, Rajiv Singh.

if isscalar(this)
  disp('Custom Regressor: ')
  dispstr = strexpression(this);

  fprintf('String expression: %s\n', dispstr)  
  G = get(this);
  %G = rmfield(G, 'Name');
  disp(G)
else
  S = size(this);
  disp(sprintf('%sx%s  array of Custom Regressors with fields: Function, Arguments, Delays, Vectorized.',...
    num2str(S(1)),num2str(S(2))))
end

% FILE END