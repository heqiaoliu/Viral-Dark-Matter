function [err, imsource] = dfpreview(dexpr, cexpr, fexpr, width, height, ds, binInfo)
% For use by DFITTOOL

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:29:07 $
%   Copyright 2001-2005 The MathWorks, Inc.

if nargin<6
    [err, data, censoring, frequency] = dfcheckselections(dexpr, cexpr, fexpr);
    if ~isequal(err, '')
        imsource = [];
        return;
    end
else
    err = '';
    data = ds.y;
    censoring = ds.censored;
    frequency=ds.frequency;
end

if nargin < 5
    width = 200;
    height = 200;
end

tempfigure=figure('units','pixels','position',[0 0 width height], ...
    'handlevisibility','callback', ...
    'integerhandle','off', ...
    'visible','off', ...
    'paperpositionmode', 'auto', ...
    'color','w');
tempaxes=axes('position',[.05 .05 .9 .9], ...
   'parent',tempfigure, ...
   'box','on', ...
   'visible','off');

% If data has a complex part, it will spit a warning to the command line, so
% turn off warnings before plotting.
warnstate=warning('off', 'all');

if nargin < 6
    binInfo = dfgetset('binDlgInfo');
elseif nargin < 7 
    binInfo = ds.binDlgInfo;
else
    % binInfo passed in
end

% If we're working on expressions rather than data in an existing data set,
% we may need to remove NaNs
[ignore1,ignore2,data,censoring,frequency] = statremovenan(data,censoring,frequency);

% Compute the bin centers using the ecdf
% to allow a quartile computation even when there is censoring.
[fstep, xstep] = ecdf(data, 'censoring', censoring, 'frequency', frequency);
[dum,binEdges] = dfhistbins(data,censoring,frequency,binInfo,fstep,xstep);

set(0,'CurrentFigure', tempfigure);
set(tempfigure,'CurrentAxes', tempaxes);

% Plot a histogram from ecdf using the computed number of bins
ecdfhist(tempaxes, fstep, xstep, 'edges', binEdges);
set(tempaxes, 'xtick',[],'ytick',[]);
axis(tempaxes,'tight');
allchildren = get(tempaxes, 'children');
patchchildren = findobj(allchildren,'flat','Type','patch');
set(patchchildren, 'facecolor', [.9 .9 .9]);
warning(warnstate);

x=hardcopy(tempfigure,'-dzbuffer','-r0');
% give the image a black edge
x(1,:,:)=0; x(end,:,:)=0; x(:,1,:)=0; x(:,end,:)=0;
imsource=im2mis(x);

delete(tempfigure);
