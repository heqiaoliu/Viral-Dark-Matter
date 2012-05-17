function [bincount,edges,C,useCenters,wng] = statgetbins(x,freq,binspec,specval)
%STATGETBINS Get bin edges from bin specification
%   This is a utility used by statistics functions to process 'bins',
%   'edges', and 'centers' arguments.

%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:30:11 $

if nargin<2
   error('stats:statgetbins:BadInput','Wrong number of input arguments.');
end

wng = ''; 
lo = double(min(x(:)));
hi = double(max(x(:)));

% May have bin count, bin centers, or bin edges.  Default is 10 bins.  If
% third arg is a string, it specifies how to interpret the fourth arg as a
% bin specification.  If third arg is a scalar, assume nbins.  Otherwise,
% assume ctrs.
useCenters = true;
if nargin < 3
    binspec = 'nbins';
    nbins = 10;
else
    if ischar(binspec)
        switch binspec
        case 'ctrs'  % ecdfhist(F,X,'ctrs',C)
            ctrs = specval(:)'; % force a row
        case 'edges' % ecdfhist(F,X,'edges',E)
            edges = specval(:)'; % force a row
            useCenters = false;
        case 'nbins' % ecdfhist(F,X,'nbins',M)
            nbins = specval;
        otherwise
            error('stats:ecdfhist:BadBinSpec', ...
                  'You must specify ''nbins'', ''ctrs'', or ''edges''.');
        end
    elseif length(binspec) == 1  % ecdfhist(F,X,M)
        nbins = binspec;
        binspec = 'nbins';
    else                         % ecdfhist(F,X,C)
        ctrs = binspec(:)'; % force a row
        binspec = 'ctrs';
    end
end

% Translate the bin spec into bin centers and edges.
switch binspec
case 'nbins'
    % If the bin count is specified:
    if isempty(x)
        lo = 0;
        hi = 1;
    end
    if lo == hi
        lo = lo - floor(nbins/2) - 0.5;
        hi = hi + ceil(nbins/2) - 0.5;
    end
    binwidth = (hi - lo) ./ nbins;
    edges = lo + binwidth*(0:nbins);
    edges(length(edges)) = hi;
    C = edges(1:end-1) + binwidth/2;
case 'ctrs'
    % Bin centers specified.  Create edges midway between the centers, and
    % symmetric about the extreme centers.
    C = ctrs;
    binwidth = diff(C);
    if any(binwidth<=0)
        error('stats:ecdfhist:NotSorted',...
              'The vector C of bin centers must be increasing.');
    end
    binwidth = [binwidth binwidth(end)];
    edges = [C(1)-binwidth(1)/2 C+binwidth/2];
    % Make sure the edges span the data.
    if ~isempty(lo)
       edges(1) = min(edges(1),lo);
       edges(end) = max(edges(end),hi);
    end
case 'edges'
    % Bin edges are specified.
    binwidth = diff(edges);
    if any(binwidth<=0)
        error('stats:ecdfhist:NotSorted',...
              'The vector E of bin edges must be increasing.');
    end
    if nargout > 2
        % Create centers that have the edges midway between them.
        C = zeros(size(binwidth));
        C(1) = edges(1) + binwidth(1)/2;
        for j = 2:length(C)
            C(j) = 2*edges(j) - C(j-1);
        end
        % It may not be possible to find centers for which the edges are
        % midpoints.  Caller may wish to warn if that's the case.
        if any(C <= edges(1:end-1)) || ...
           abs(C(end) - (edges(end)-binwidth(end)/2)) > 1000*eps(binwidth(end));
            wng = 'Cannot compute centers that are consistent with EDGES.';
            C = edges(1:end-1) + binwidth/2;
        end
    end
    % The edges may or may not span the data.
    if ~isempty(x) && ((lo < edges(1)) || (edges(end) < hi))
        warning('stats:ecdfhist:DataNotSpanned',...
                'The vector E of bin edges does not span the range of X.');
    end
end

% Update bin widths for internal bins
nbins = length(edges) - 1;

if isempty(x)
    binnum = x;
elseif useCenters
    % Shift bins so the internal is ( ] instead of [ ).
    edges = edges + eps(edges);
    % Map each jump location to a bin number. -Inf accounts for the above
    % shift, +Inf keeps things out of histc's degenerate rightmost bin.
    [ignore,binnum] = histc(x,[-Inf edges(2:end-1) Inf]);
else
    % Map each jump location to a bin number.  Only jumps that are within
    % the closed interval from edges(1) to edges(end) get counted.
    [ignore,binnum] = histc(x,edges);
    % Merge histc's degenerate rightmost bin with the last "real" bin, and
    % ignore anything out of range.
    binnum(binnum==nbins+1) = nbins;
end
        
if any(binnum==0)
    freq(binnum==0) = [];
    binnum(binnum==0) = [];
end

% Compute the probability for each bin
binnum = binnum(:);
bincount = accumarray([ones(size(binnum)),binnum],freq,[1,nbins]);
