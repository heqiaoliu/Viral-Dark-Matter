function args = designargs(this, hspecs)
%DESIGNARGS   Return the arguments for MAXFLAT

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:46 $

upass = convertmagunits(hspecs.Apass/2,'db','linear','pass');
lpass = -upass;
ustop = convertmagunits(hspecs.Astop,'db','linear','stop');

if this.Zerophase
    lstop = 0;
else
    lstop = -ustop;
end

poffsetlinear = convertmagunits(this.PassbandOffset,'db','linear','amplitude');

up = [upass+poffsetlinear ustop]; lo = [lpass+poffsetlinear lstop];
A0 = (up(1) + lo(1))/2;
A = [A0 0];
F = [0 hspecs.Fcutoff 1];
args = {hspecs.FilterOrder, F, A, up, lo};
