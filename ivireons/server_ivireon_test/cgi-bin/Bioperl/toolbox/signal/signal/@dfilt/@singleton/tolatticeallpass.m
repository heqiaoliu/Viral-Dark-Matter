function Hd2 = tolatticeallpass(Hd);
%TOLATTICEALLPASS  Convert to lattice allpass.
%   Hd2 = TOLATTICEALLPASS(Hd) converts discrete-time filter Hd to lattice
%   allpass filter Hd2.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:09:54 $
  
if ~isallpass(Hd),
    error(generatemsgid('DFILTErr'),'The filter to convert must have allpass sections.');
end

[b,a] = tf(Hd);
k = tf2latc(b,a);
Hd2 = dfilt.latticeallpass(k);
