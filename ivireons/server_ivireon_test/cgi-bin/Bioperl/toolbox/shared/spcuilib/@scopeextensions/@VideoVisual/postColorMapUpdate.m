function postColorMapUpdate(this,~)
%POSTCOLORMAPUPDATE   Update the display after a change in color map

%   Author(s): H. Dannelongue
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  Date: $

% Get the   current data and update
source= this.Application.DataSource;
if ~isempty(source)
    update(this);
    postUpdate(this);
end

% [EOF]
