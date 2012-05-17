function hRemove = removeListener(this,L)
% REMOVELISTENER method to remove listener
%
% removed = this.removeListner(L)
%
% Inputs:
%    L  - optional handle.listener argument of listener to remove, if
%         omitted all listeners are removed
%
% Outputs:
%   removed - vector of removed handle.listener objects
%

 
% Author(s): A. Stothert 11-Apr-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/04/28 03:26:03 $

%Find which Listeners to remove
if nargin<2
   idx = true(size(this.Listeners));
else
   idx = L == this.Listeners;
end

%Remove the identified listeners
hRemove             = this.Listeners(idx);
this.Listeners(idx) = [];
