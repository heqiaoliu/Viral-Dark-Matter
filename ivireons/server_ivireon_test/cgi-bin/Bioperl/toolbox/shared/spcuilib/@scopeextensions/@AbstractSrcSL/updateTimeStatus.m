function updateTimeStatus(this)
% UPDATETIMESTATUS Update the TimeStatus field 

%   Author(s): H. Dannelongue
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/31 18:41:13 $

try
    this.TimeStatus.Text = sprintf('T=%.3f', this.TimeOfDisplayData);
catch ME %#ok<NASGU>
    this.TimeStatus = this.Controls.StatusBar.findwidget({'StdOpts','Frame'});
    this.TimeStatus.Text = sprintf('T=%.3f', this.TimeOfDisplayData);
end

% [EOF]
