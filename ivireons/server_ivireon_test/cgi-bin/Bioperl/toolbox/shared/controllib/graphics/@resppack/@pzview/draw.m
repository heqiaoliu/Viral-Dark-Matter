function draw(this, Data,NormalRefresh)
%  DRAW  Draw method for the @pzview class to generate the response curves.

%  Author(s): John Glass, Bora Eryilmaz, Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:23:02 $

% Recompute the curves
for ct = 1:prod(size(Data.Poles))
   set(double(this.PoleCurves(ct)), 'XData', real(Data.Poles{ct}), ...
      'YData', imag(Data.Poles{ct}));
   set(double(this.ZeroCurves(ct)), 'XData', real(Data.Zeros{ct}), ...
      'YData', imag(Data.Zeros{ct}));
end
