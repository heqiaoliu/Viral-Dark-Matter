function b = genmcode(h, d)
%GENMCODE Generate MATLAB code

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.4.8 $  $Date: 2010/01/25 22:51:49 $

b = sigcodegen.mcodebuffer;

[p,v] = abstract_genmcode(h, d);
p{end+1} = 'match';
v{end+1} = sprintf('''%s''', get(d, 'MatchExactly'));

b.addcr(b.formatparams(p,v));
b.cr;
b.addcr(designdesc(d));
b.addcr('h  = fdesign.highpass(Fstop, Fpass, Astop, Apass%s);', getfsinput(d));
b.add('Hd = design(h, ''ellip'', ''MatchExactly'', match);');

% [EOF]
