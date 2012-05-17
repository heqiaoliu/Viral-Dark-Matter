function h = iscatter(x,y,i,c,m,msize)
%ISCATTER Scatter plot grouped by index vector.
%   ISCATTER(X,Y,I,C,M,msize) displays a scatter plot of X vs. Y grouped
%   by the index vector I.  
%
%   No error checking.  Use GSCATTER instead.
%
%   See also GSCATTER, GPLOTMATRIX.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/22 04:41:25 $

xcols = size(x,2);
ycols = size(y,2);
ncols = max(xcols,ycols);

ni = max(i); % number of groups
if (isempty(ni))
   i = ones(size(x,1),1);
   ni = 1;
end

nm = length(m);
ns = length(msize);
if ischar(c) && isvector(c)
    c = c(:);
end
nc = size(c,1);

% Now draw the plot
for j=1:ni
   ii = (i == j);
   nii = sum(ii);
   if nii==0
       % degenerate case, create lines with NaN data
       for k=1:ncols
           hh(j,k) = line(NaN,NaN, ...
              'LineStyle','none', 'Color', c(1+mod(j-1,nc),:), ...
              'Marker', m(1+mod(j-1,nm)), 'MarkerSize', msize(1+mod(j-1,ns)));
       end
   elseif nii==1 && xcols>1 && ycols>1
       % degenerate case, avoid plotting two row vectors in one line
       for k=1:ncols
           hh(j,k) = line(x(ni,k),y(ni,k), ...
              'LineStyle','none', 'Color', c(1+mod(j-1,nc),:), ...
              'Marker', m(1+mod(j-1,nm)), 'MarkerSize', msize(1+mod(j-1,ns)));
       end
   else
       % normal case, create lines for each column pair at once
       hh(j,:) = line(x(ii,:), y(ii,:), ...
              'LineStyle','none', 'Color', c(1+mod(j-1,nc),:), ...
              'Marker', m(1+mod(j-1,nm)), 'MarkerSize', msize(1+mod(j-1,ns)));
   end
end

% Return the handles if desired.  They are arranged so that even if X
% or Y is a matrix, the first ni elements of hh(:) represent different
% groups, so they are suitable for use in drawing a legend.
if (nargout>0)
   h = hh(:);
end

