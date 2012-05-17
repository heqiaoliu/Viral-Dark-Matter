function draw(this, Data,NormalRefresh)
%DRAW  Draws Nyquist response curves.
%
%  DRAW(VIEW,DATA) maps the response data in DATA to the curves in VIEW.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:22:36 $

[Ny, Nu] = size(this.PosCurves);
for ct = 1:Ny*Nu
   % REVISIT: remove conversion to double (UDD bug where XOR mode ignored)
   H = Data.Response(:,ct);
   set(double(this.PosCurves(ct)), 'XData', real(H), 'YData', imag(H));
   if this.ShowFullContour
      % REVISIT: incorrect for complex systems!
      set(double(this.NegCurves(ct)), 'XData', real(H), 'YData', -imag(H));
   else
      set(double(this.NegCurves(ct)), 'XData',[],'YData',[])
   end
end
set(double([this.PosArrows,this.NegArrows]),'XData',[],'YData',[])  % for quick refresh 
