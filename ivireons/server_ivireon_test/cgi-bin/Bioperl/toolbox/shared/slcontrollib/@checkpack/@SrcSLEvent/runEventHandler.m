function runEventHandler(this,event)  %#ok<INUSD>
% RUNEVENTHANDLER process run events
%
 
% Author(s): A. Stothert 15-Dec-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:51:12 $

%If there is a view open reset displayed responses
hView = this.Application;
if this.ActiveSource && ~isempty(hView) && ishandle(hView.Visual)
   hView.Visual.runEventHandler;
end
end