function addtip(this,tipfcn,info)
%ADDTIP  Adds line tip to each curve in each view object

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:27:32 $
for ct1 = 1:size(this.Curves,1)
   for ct2 = 1:size(this.Curves,2)
      info.Row = ct1; info.Col = ct2;
      this.installtip(this.Curves(ct1,ct2),tipfcn,info)
   end
end