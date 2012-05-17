function addlisteners(this,L)
%ADDLISTENERS  Default implementation.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:29:13 $

% Initialization. First install generic listeners
if nargin==1
   this.generic_listeners;
else
   this.Listeners.addListeners(L);
end