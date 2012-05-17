function this = DDGGC(tcpeer)
%

% Constructor for selsigviewDDGView

%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/22 04:26:10 $

this = sigselector.DDGGC;    
this.TCPeer = tcpeer;
cb = @(h,ev) update(this,h,ev);
M(1) = addlistener(tcpeer,'ComponentChanged', cb);
M(2) = addlistener(tcpeer, 'ObjectBeingDestroyed', @(x,y) delete(this));
this.TCListeners = M;



