function title = getTitle(this)
%GETTITLE Get the title to be displayed on the Axes.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/31 18:41:31 $

title = '';
if ~(this.NTXFeaturedOn)
    if ~isempty(this.Application.DataSource)
        title = sprintf('%s','Log2 Histogram');
    end
end
   

% [EOF]
