function resize(this,Ny)
%RESIZE  Adjusts input plot to fill all available rows.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:38 $
Curves = this.Curves;
nobj = length(Curves);
if nobj>Ny
   delete(Curves(Ny+1:nobj))
   this.Curves = Curves(1:Ny);
else
   p = this.Curves(1).Parent;
   for ct=Ny:-1:nobj+1
      % UDDREVISIT
      Curves(ct,1) = handle(copyobj(Curves(1),p));
   end
   this.Curves = Curves;
end