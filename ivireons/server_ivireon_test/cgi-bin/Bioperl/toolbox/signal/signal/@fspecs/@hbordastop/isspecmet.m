function SpecMetFlag = isspecmet(this,b)
%ISSPECMET True if the object spec is met

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 04:36:23 $

hfilter = dfilt.dffir(b);
if ishp(this)
    hfilter = firlp2hp(hfilter);
    hfdesign = fdesign.halfband('N,Ast',this.FilterOrder,this.Astop,'Type','Highpass');
else
    hfdesign = fdesign.halfband('N,Ast',this.FilterOrder,this.Astop);
end
m = measure(hfilter,hfdesign);
SpecMetFlag = isspecmet(m);

% [EOF]
