function [Dila, Tran] = multgrid(x, config)
%MULTGRID: build pyramidal multi-grids according to the data sample.
%
%[Dila, Tran] = multgrid(x, config)
%
%x: input or regressor data sample, a N*dimx matrix
%config: a structure containing config parameters
%   fields of config:
%        mincells:  min number of cells in the multi-grids
%        maxcells:  max number of cells in the multi-grids
%        minpoints: min number of data points a cell should contain
%        maxlevels: max number of scaling levels 
%        dilastep:  dilation step size (a)
%        transtep:  translation step size (b)
%
%Dila and Tran: dilation and translation parameters defining the multi-grids.
%
%Algorithm:
%
%For each dilation level, find out in which cell each data point falls.
%Sort the cells containing at least one point, then count the number of
%points in each cell. Remove the cells containing less than minpoints
%data points.
%
%LocalFindtran is called to find out the cells containing more than
%minpoints data points.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 21:02:57 $

% Author(s): Qinghua Zhang

a = config.DilationStep;
b = config.TranslationStep;

minpoints = config.FinestCell;

maxlevels = config.MaxLevels; 
maxcells = config.MaxCells; 

smprintf('\nBuilding the multi-grids .');

[N, dimx] = size(x);

Tran = [];
Dila = [];


dilal = 1;  % Initialize dilation of level l;

for l=1:maxlevels
 
  smprintf('.');

  dilaoverb = dilal / b; 

  % compute round(x * dilal / b)
  tranint = LocalFindtran(round(x * dilaoverb), minpoints);

  if isempty(tranint)   %If no well filled cell was found
    l = l-1; break; 
  end

  Tran = [Tran; tranint./dilaoverb];        % scale back
  Dila = [Dila; dilal(ones(size(tranint,1),1))];

  if size(Tran,1)>=maxcells  %Do not build too many cells.
    break;
  end

  dilal = dilal * a;     % for the next level, dilal gains one more factor a.
end

smprintf('\nNumber of grid levels: %d\n', l);
smprintf('Number of cells in the grids: %d\n', size(Dila,1));


%============================Local Functions=================================
function tranint = LocalFindtran(xint, minpoints)
%tranint = LocalFindtran(xint, minpoints)
%
%Find out the cells of multi-grids containing more than
%minpoints data points.
%
%tranint indicates the found cells, xint indicates the cells containing
%at least one data point (with possible multiple occurrence).
%
%LocalVectsort.m is called to sort the cells containing at least one data point.
%then the number of points in each cell is counted. Finally the cells 
%containing less than minpoints data points are removed.

N = size(xint, 1);

if N<=1    % handle too few data case 
  tranint = xint;

else
  xint = LocalVectsort(xint);

  ind = any(diff(xint), 2);

  headind = find([1; ind]);

  repeatnb = diff([headind; N+1]);

  tranint = xint(headind(find(repeatnb>=minpoints)), :);
end


%-----------------------------------------------------------------------------
function [y, I] = LocalVectsort(x)
%[y, I] = LocalVectsort(x)
%
%Vectorial sorting.
%
%Consider each row of the matrix x as a "number" whose entries are the
%"figures", then these "numbers" are sorted in ascending order.
%I contains the sorted indexes, y is the sorted matrix.

[N, dimx] = size(x);

I = (1:N)';

for i=dimx:(-1):1
  [dum, ind] = sort(x(I, i));
  I = I(ind);
end

y = x(I, :);

% FILE END
