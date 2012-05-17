function a = setuserdata(a,newdata)
%SETUSERDATA Set dataset array UserData property.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:38:17 $

if nargin < 2
    error('stats:dataset:setuserdata:TooFewInputs', ...
          'Requires at least two inputs.');
end

a.props.UserData = newdata;
