function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/05/04 01:50:50 $


% Set up design params
Nb = get(d,'numOrder');

Na = get(d,'denOrder');

% Get frequency specs, they have been prenormalized
Fc = get(d,'Fc');

[b,a,b1,b2,sos,g] = maxflat(Nb,Na,Fc);

% Construct object
Hd = dfilt.df2sos(sos,g);



