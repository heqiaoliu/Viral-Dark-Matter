function specification = getSpecification(this, laState)
%GETSPECIFICATION   Get the specification.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:56:40 $

if nargin < 2
    laState = this;
end

if strcmp(laState.OrderMode2, 'Order')
    if strcmp(laState.FrequencyConstraints, 'Bandwidth')
        specification = 'N,BW';
    else
        specification = 'N,Q';
    end
else
    specification = 'L,BW,GBW,Nsh';
end

% [EOF]
