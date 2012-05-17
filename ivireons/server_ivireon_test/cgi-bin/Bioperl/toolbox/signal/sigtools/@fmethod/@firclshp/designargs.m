function args = designargs(this, hspecs)
%DESIGNARGS   Return the arguments for MAXFLAT

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:37:41 $

upass = convertmagunits(hspecs.Apass/2,'db','linear','pass');
lpass = -upass;
ustop = convertmagunits(hspecs.Astop,'db','linear','stop');

if this.Zerophase
    lstop = 0;
else
    lstop = -ustop;
end

poffsetlinear = convertmagunits(this.PassbandOffset,'db','linear','amplitude');

up = [ustop upass+poffsetlinear]; lo = [lstop lpass+poffsetlinear];
A0 = (up(2) + lo(2))/2;
A = [0 A0];
F = [0 hspecs.Fcutoff 1];
args = {hspecs.FilterOrder, F, A, up, lo};
