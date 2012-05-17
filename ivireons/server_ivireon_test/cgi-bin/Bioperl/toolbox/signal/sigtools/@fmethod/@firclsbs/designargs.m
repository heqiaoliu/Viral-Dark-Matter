function args = designargs(this, hspecs)
%DESIGNARGS   Return the arguments for MAXFLAT

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:32 $

upass1 = convertmagunits(hspecs.Apass1/2,'db','linear','pass');
lpass1 = -upass1;
ustop = convertmagunits(hspecs.Astop,'db','linear','stop');
upass2 = convertmagunits(hspecs.Apass2/2,'db','linear','pass');
lpass2 = -upass2;

if this.Zerophase
    lstop = 0;
else
    lstop = -ustop;
end

poffsetlinear1 = convertmagunits(this.PassbandOffset(1),'db','linear','amplitude');
poffsetlinear2 = convertmagunits(this.PassbandOffset(2),'db','linear','amplitude');

up = [upass1+poffsetlinear1 ustop upass2+poffsetlinear2];
lo = [lpass1+poffsetlinear1 lstop lpass2+poffsetlinear2 ];
A1 = (up(1)+lo(1))/2;
A2 = (up(3)+lo(3))/2;

A = [A1 0 A2];
F = [0 hspecs.Fcutoff1 hspecs.Fcutoff2 1];
args = {hspecs.FilterOrder, F, A, up, lo};
