
function Hd2 = tolatticemamin(Hd);
%TOLATTICEMAMIN  Convert to lattice moving-average.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2009/09/03 05:27:52 $
  
if ~isfir(Hd)
  error(generatemsgid('DFILTErr'),'The filter to convert must be FIR');
end
[b,a] = tf(Hd);
b = b/a(1);
if b(1)~=1,
    b = b/b(1);
    warning(generatemsgid('GainIntroduced'), ...
        ['The conversion to the lattice structure will introduce a gain of ',num2str(20*log10(1/b(1))), ' dB at DC.']);
end
k = tf2latc(b);
Hd2 = dfilt.latticemamin(k);
