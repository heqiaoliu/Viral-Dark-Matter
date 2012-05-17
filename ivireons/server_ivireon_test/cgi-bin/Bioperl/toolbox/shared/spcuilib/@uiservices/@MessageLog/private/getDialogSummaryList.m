function [hdr,tbl,idx] = getDialogSummaryList(hMessageLog)
%getDialogSummaryList Return header and listbox for message summaries.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2008/05/20 00:20:39 $

% Find longest string in category list, used
% to properly format width of category column
maxCatWidth = max(cellfun(@numel,catList(hMessageLog)));
catWidth = max(maxCatWidth,numel('Category'));

% Create header format string
% We must compute the max width of the category field to do this
hdrfmt = ['%-4s %-' sprintf('%d',catWidth) 's %-25s'];
hdrstr = {'Type','Category','Summary'};
hdr = sprintf(hdrfmt,hdrstr{:});

% need extra leading space to better align header with table
hdr = [' ' hdr];

% Get popup choices for filters:
%   Type ('all', or a specific type to show)
%   Category ('all', or a specific category to show)
[mType,mCat] = getDialogTypeCat(hMessageLog);
allType = strcmpi(mType,'all');
allCat  = strcmpi(mCat,'all');

% Get/create merged log, which includes all messages
% from this log plus any linked logs:
hMergedLog = cacheMergedLog(hMessageLog);

% Build summary from last to first
tbl = {};
idx = []; % hold msg index, 0=last, 1=2nd to last, etc
i=0;      % current msg index, starting at last msg
hMsg = hMergedLog.down('last'); % last child;
while ~isempty(hMsg)
    if (allType || strcmpi(hMsg.Type,mType)) && ...
       (allCat  || strcmp(hMsg.Category,mCat))
   
       % Add this message
       tbl = [tbl {sprintf(hdrfmt, ...
           capital(hMsg.Type), ...
           hMsg.Category, ...
           hMsg.Summary)}]; %#ok
       % Record index into full msg list
       idx = [idx i]; %#ok
    end
    hMsg = hMsg.left; % go to earlier msg
    i=i+1;
end

% Work around for DAStudio change which respect to blank spaces in
% listboxes. g375407
tbl = strrep(tbl, ' ', '&nbsp;');

% [EOF]
