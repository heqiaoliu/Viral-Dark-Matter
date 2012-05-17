function this = invfreqz
%INVFREQZ   Construct an INVFREQZ object.

%   Author(s): V. Pellissier
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/06/27 23:40:17 $

this = fmethod.invfreqz;
this.FilterStructure = 'df2';
this.DesignAlgorithm = 'IIR least-squares';

% [EOF]
