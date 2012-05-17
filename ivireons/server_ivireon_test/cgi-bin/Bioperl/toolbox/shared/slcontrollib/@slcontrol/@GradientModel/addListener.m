function addListener(this,L) 
% ADDLISTENER method to add a listener
%
 
% Author(s): A. Stothert 11-Apr-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/04/28 03:26:02 $

this.Listeners = [this.Listeners; L];
this.Listeners = this.Listeners(ishandle(this.Listeners));
