function DGDF = dg_dfilt(Stages, Label, expandOrientation)
%DG_DFILT Constructor for this class.

%   Author(s): Roshan R Rammohan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:17 $

error(nargchk(1,3,nargin,'struct'));

DGDF = filtgraph.dg_dfilt;

DGDF.stage = Stages;

if nargin > 1
    DGDF.label = Label;
end

if nargin > 2
    DGDF.expandOrientation = expandOrientation;
end

