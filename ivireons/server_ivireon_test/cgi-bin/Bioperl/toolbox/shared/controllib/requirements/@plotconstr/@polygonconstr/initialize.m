function initialize(Constr,iConstr)
%INITIALIZE   Initializes rectangular constraint objects

%   Author(s): N. Hickey, A. Stothert
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:41 $

if nargin<2, iConstr = 1:numel(Constr); end

for idx = iConstr
   % Add generic listeners and mouse event callbacks
   Constr(idx).addlisteners;

   % Add @rectelement-specific listeners
   Listener = ...
      handle.listener(Constr(idx),Constr(idx).findprop('SelectedEdge'),...
      'PropertyPostSet', @(hSrc,hData) localUpdateEdge(Constr(idx)));
   Constr(idx).addlisteners(Listener);
end

%--------------------------------------------------------------------------
function localUpdateEdge(Constr)

Constr.update