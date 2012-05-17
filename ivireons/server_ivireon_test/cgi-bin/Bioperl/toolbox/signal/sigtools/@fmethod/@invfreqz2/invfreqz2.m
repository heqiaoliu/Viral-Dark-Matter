function this = invfreqz2
%INVFREQZ2   Construct an INVFREQZ2 object.

%   Author(s): V. Pellissier
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:40:18 $

this = fmethod.invfreqz2;

this.FilterStructure = 'df2';
this.DesignAlgorithm = 'IIR Least-Squares';

% [EOF]
