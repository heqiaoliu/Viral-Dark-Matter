function javaudd=dftoolgetudd(uddcmd,varargin);

%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:29:20 $
%   Copyright 2003-2004 The MathWorks, Inc.

% unwrap any UDD objects
for i=1:length(varargin)
   if isa(varargin{i}, 'com.mathworks.jmi.bean.UDDObject')
      varargin{i}=handle(varargin{i});
   end
end

% wrap the return UDD object
if nargin == 1
   javaudd=java(eval(uddcmd));
else
   javaudd=java(feval(uddcmd,varargin{:}));
end
