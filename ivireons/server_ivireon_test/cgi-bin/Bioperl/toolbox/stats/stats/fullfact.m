function design = fullfact(levels)
%FULLFACT Mixed-level full-factorial designs.
%   DESIGN=FULLFACT(LEVELS) creates a matrix DESIGN containing the
%   factor settings for a full factorial design. The vector LEVELS
%   specifies the number of unique settings in each column of the design.
%
%   Example:
%       LEVELS = [2 4 3];
%       DESIGN = FULLFACT(LEVELS);
%   This generates a 24 run design with 2 levels in the first column,
%   4 in the second column, and 3 in the third column.

%   Copyright 1993-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:13:56 $

[m,n] = size(levels);
if ~isfloat(levels)
   levels = double(levels);
end

if min(m,n) ~= 1
   error('stats:fullfact:VectorRequired','Requires a vector input.');
end

if any(floor(levels) ~= levels) || any(levels < 1)
   error('stats:fullfact:IntegersRequired',...
         'The input values must be positive integers.');
end

ssize = prod(levels);
ncycles = ssize;
cols = max(m,n);

design = zeros(ssize,cols,class(levels));

for k = 1:cols
   settings = (1:levels(k));                % settings for kth factor
   nreps = ssize./ncycles;                  % repeats of consecutive values
   ncycles = ncycles./levels(k);            % repeats of sequence
   settings = settings(ones(1,nreps),:);    % repeat each value nreps times
   settings = settings(:);                  % fold into a column
   settings = settings(:,ones(1,ncycles));  % repeat sequence to fill the array
   design(:,k) = settings(:);
end
