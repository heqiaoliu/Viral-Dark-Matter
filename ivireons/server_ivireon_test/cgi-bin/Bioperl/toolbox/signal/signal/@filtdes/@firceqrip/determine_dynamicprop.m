function propname = determine_dynamicprop(d,freqspec,freqspecOpts)

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:09:39 $


switch freqspec
case freqspecOpts{1}, %'cutoff'
    propname = 'Fc';
case freqspecOpts{2}, %'passedge'
    propname = 'Fpass';
case freqspecOpts{3}, %'stopedge'
    propname = 'Fstop';
end