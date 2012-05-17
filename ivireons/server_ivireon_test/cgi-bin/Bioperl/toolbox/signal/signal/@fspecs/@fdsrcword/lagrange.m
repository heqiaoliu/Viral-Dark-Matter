function Hd = lagrange(this, varargin)
%LAGRANGE   

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 22:44:32 $

h = feval(getdesignobj(this, 'lagrange'));
if length(varargin) > 1,
    % p-v pair specified
    set(h,varargin{:});
end
Hd = design(h,this);


% [EOF]
