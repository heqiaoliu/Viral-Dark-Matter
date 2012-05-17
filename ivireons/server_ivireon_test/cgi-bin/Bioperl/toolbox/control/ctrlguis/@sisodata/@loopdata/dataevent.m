function dataevent(this,Scope,C)
%DATAEVENT  Issues LoopDataChanged event

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $ $Date: 2005/11/15 00:47:58 $

% RE: Scope = what has changed (all|gain)
%     C = what component was modified
if nargin<3
   C = [];
end

% Clear derived data
this.reset(Scope,C);

% Broadcast event
this.EventData.Scope = Scope;
this.EventData.Component = C;
this.send('LoopDataChanged')
