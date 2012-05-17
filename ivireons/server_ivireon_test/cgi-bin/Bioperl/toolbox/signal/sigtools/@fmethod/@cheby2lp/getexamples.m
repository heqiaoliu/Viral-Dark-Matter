function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/10/23 18:54:20 $

examples = {{ ...
    'Design a lowpass Chebyshev type II filter in the DF2TSOS structure.', ...
    'h  = fdesign.lowpass(''N,Fst,Ast'');', ...
    'Hd = design(h, ''cheby2'', ''FilterStructure'', ''df2tsos'');'}};

% [EOF]
