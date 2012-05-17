function display(this)
% Display method for @variable class

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2005/12/22 18:14:56 $

% Display inputname
InputName = inputname(1);
if isempty(InputName)
   InputName = 'ans';
end
fprintf('\n%s =\n\n',InputName)

% Display variable name(s)
for ct=1:length(this)
   fprintf('Data set variable %s\n',this(ct).Name)
end