function b = genmcode(h, d)
%GENMCODE Returns the MCode necessary to generate the filter.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:10:18 $

[params, values, descs, str] = fir1_genmcode(d);
[aparams, avalues, adescs]   = abstract_genmcode(h, d);

b = sigcodegen.mcodebuffer;

b.addcr(b.formatparams({aparams{:}, params{:}}, ...
    {avalues{:}, values{:}}, {adescs{:}, descs{:}}));
b.cr;
b.addcr(minorddesc(h, 'kaiserord'));
b.addcr('[N,Wn,BETA,TYPE] = kaiserord([Fpass Fstop]%s, [1 0], [Dstop Dpass]);', getfsstr(d));
b.cr;
b.addcr(designdesc(d));
b.addcr('b  = fir1(N, Wn, TYPE, kaiser(N+1, BETA), flag);');
b.add('Hd = dfilt.dffir(b);');

% [EOF]