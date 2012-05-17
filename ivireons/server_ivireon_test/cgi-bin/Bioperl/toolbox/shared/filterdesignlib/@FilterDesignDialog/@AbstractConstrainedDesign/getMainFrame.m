function main = getMainFrame(this)
%GETMAINFRAME Get the mainFrame.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:15:56 $

% Set up the first tab.
header = getHeaderFrame(this);
header.RowSpan = [1 1];
header.ColSpan = [1 1];

fspecs = getFrequencySpecsFrame(this);
fspecs.RowSpan = [2 2];
fspecs.ColSpan = [1 1];

mspecs = getMagnitudeSpecsFrame(this);
mspecs.RowSpan = [3 3];
mspecs.ColSpan = [1 1];

design = getDesignMethodFrame(this);
design.RowSpan = [4 4];
design.ColSpan = [1 1];

main.Type       = 'panel';
main.Items      = {header, fspecs, mspecs, design};
main.LayoutGrid = [5 1];
main.RowStretch = [0 0 0 0 3];
main.Tag        = 'MainPanel';

% [EOF]
