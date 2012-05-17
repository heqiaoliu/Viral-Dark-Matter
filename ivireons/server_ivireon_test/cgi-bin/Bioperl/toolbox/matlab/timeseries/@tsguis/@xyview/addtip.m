function addtip(this,tipfcn,info)
%ADDTIP  Adds line tip to each curve in each view object

%   Author(s):  
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/15 20:58:34 $

%% Overloaded since parent class does not implement
viewer = tsguis.tsviewer;
if ~viewer.DataTipsEnabled
    return
end
for ct1 = 1:size(this.Curves,1)
   for ct2 = 1:size(this.Curves,2)
      info.Row = ct1; info.Col = ct2;
      this.installtip(this.Curves(ct1,ct2),tipfcn,info)
   end
end