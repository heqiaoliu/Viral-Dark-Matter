function addlisteners(this,L)
%  ADDLISTENERS  Installs additional listeners for @nicholsplot class.

%  Author(s): Bora Eryilmaz
%  Revised:
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:21:53 $

if nargin == 1
  % Initialization. First install generic listeners
  this.generic_listeners;

  % Add @nicholsplot specific listeners
  % set(L, 'CallbackTarget', this);
else
    this.Listeners.addListeners(L);
end


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%
