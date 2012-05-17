function fq = get_filterquantizer(this, fq)
%get the filterquantizer for the first stage of multistage filters.

%   Author(s): Honglei Chen
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:44:43 $

fq = get_filterquantizer(this.Stage(1));

% [EOF]
