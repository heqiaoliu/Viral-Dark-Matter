function net = loadobj(obj)
%LOADOBJ Load a network object.
%
%  <a href="matlab:doc loadobj">loadobj</a>(NET) is automatically called with a structure when
%  a network is loaded from a MAT file.  If the network is from a
%  previous version of the Neural Network Toolbox software then
%  it is updated to the latest version.

% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.4.4.2 $ $Date: 2010/04/24 18:07:34 $

if isa(obj,'network')
  net = obj;
else
  net = nnupdate.net(obj);
end
