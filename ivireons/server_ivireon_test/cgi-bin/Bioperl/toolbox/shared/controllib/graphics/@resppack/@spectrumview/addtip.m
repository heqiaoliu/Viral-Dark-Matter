function addtip(this,tipfcn,info)
%ADDTIP  Adds line tip to @Spectrumview

%  Author(s): Erman Korkut 23-Mar-2009
%  Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:10 $

% Make the interpolation nearest
info.TipOptions = {'InterpolationMethod','nearest'};

for ct1 = 1:size(this.Curves,1)
   for ct2 = 1:size(this.Curves,2)
      info.Row = ct1; info.Col = ct2;
      this.installtip(this.Curves(ct1,ct2),tipfcn,info)
   end
end