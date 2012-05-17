function unrender(this)
%UNRENDER Remove table widgets

%	@commgui\@table
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:17:32 $

% Remove column labels
delete(this.ColumnLabelHandles);

% Remove rows
delete(this.RowHandles);

% Remove buttons
delete(this.UpControl);
delete(this.DownControl);

% Mark as unrendered
this.Rendered = 0;

%-------------------------------------------------------------------------------
% [EOF]
