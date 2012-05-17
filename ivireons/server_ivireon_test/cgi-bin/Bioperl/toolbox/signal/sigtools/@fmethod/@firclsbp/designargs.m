function args = designargs(this, hspecs)
%DESIGNARGS   Return the arguments for MAXFLAT

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:26 $

upass = convertmagunits(hspecs.Apass/2,'db','linear','pass');
lpass = -upass;
ustop1 = convertmagunits(hspecs.Astop1,'db','linear','stop');
ustop2 = convertmagunits(hspecs.Astop2,'db','linear','stop');

if this.Zerophase
    lstop1 = 0;
    lstop2 = 0;
else
    lstop1 = -ustop1;
    lstop2 = -ustop2;
end

poffsetlinear = convertmagunits(this.PassbandOffset,'db','linear','amplitude');

up = [ustop1 upass+poffsetlinear ustop2]; lo = [lstop1 lpass+poffsetlinear lstop2];
A0 = (up(2)+lo(2))/2;
A = [0 A0 0];
F = [0 hspecs.Fcutoff1 hspecs.Fcutoff2 1];
args = {hspecs.FilterOrder, F, A, up, lo};
