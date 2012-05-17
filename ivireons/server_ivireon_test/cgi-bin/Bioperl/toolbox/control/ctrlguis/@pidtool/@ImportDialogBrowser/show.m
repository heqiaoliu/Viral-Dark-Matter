function show(this) 
% SHOW  Enter a description here!
%
 
% Author(s): Rong Chen 10-Mar-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:21:57 $

this.Frame.pack;
centerfig(this.Frame,this.Tuner.Handles.Figure);
this.Frame.setVisible(true);
