function segment=segment(obj,q,p)
%SEGMENT Segment of piecewise distribution containing input values.
%    S=SEGMENT(OBJ,X,P) returns an array S of integers indicating which
%    segment of the piecewise distribution object OBJ contains each value
%    in the array X or P.  X and P cannot both be specified as non-empty.
%    If X is not empty, the result S is determined by comparing X with
%    the quantile boundary values defined for OBJ.  If P is not empty,
%    the result S is determined by comparing P with the probability
%    boundary values.
%
%    See also PIECEWISEDISTRIBUTION, PIECEWISEDISTRIBUTION/BOUNDARY, PIECEWISEDISTRIBUTION/NSEGMENTS.

%   Copyright 2006-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:21:08 $

if nargin<2
    error('MATLAB:nargchk:notEnoughInputs','Not enough input arguments.');
end
if nargin<3
    p = [];
end

if (isempty(p) && isempty(q)) || (~isempty(p) && ~isempty(q))
    error('stats:piecewisedistribution:segment:BadArgs',...
          'P or Q (but not both) must be empty.');

elseif isempty(p)
    % Determine which segment each point occupies based on quantile
    bins = [-Inf; obj.Q; Inf];
    x = q;
    
else % isempty(q)
    % Determine which segment each point occupies based on probability
    bins = [0; obj.P; 1];
    x = p;
end

% Use histc to assign segments
[nbins,segment] = histc(x(:),bins);
segment = reshape(segment,size(x));


% Merge edge cases into the appropriate segment
maxseg = numel(nbins)-1;
segment(segment>maxseg) = maxseg;
segment(x==bins(1)) = 1;
