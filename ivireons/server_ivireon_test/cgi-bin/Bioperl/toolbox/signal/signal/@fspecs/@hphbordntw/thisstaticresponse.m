function thisstaticresponse(this, hax)
%THISSTATICRESPONSE   

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/23 18:49:05 $

if this.NormalizedFrequency, str = '.5';
else,                        str = 'Fs/4'; end

staticrespengine('drawpassband',   hax, [0.55  1], [.9 1.1]);
staticrespengine('drawtransition', hax, [.45 .55]);
staticrespengine('drawstopband',   hax, [0   .45]);
staticrespengine('drawfreqlabels', hax, .5, str);

% [EOF]