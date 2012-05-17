function out1 = template_distance(in1,in2)
%TEMPLATE_TRANSFER Template distance function.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  WARNING - Future versions of the toolbox may require you to update
%  custom functions.
%
%  Directions for Customizing
%
%    1. Make a copy of this function with a new name
%    2. Edit your new function according to the code comments marked ***
%    3. Type HELP NNTRANSFER to see a list of other distance functions.
%
%  Syntax
%
%    d = template_transfer(pos);
%
%  Description
%
%    TEMPLATE_TRANSFER(pos) takes one argument,
%      POS - NxS matrix of neuron positions.
%    and returns the SxS matrix of distances.
%
%  Network Use
%
%    To change a network so a layer's topology uses TEMPLATE_TRANSFER set
%    NET.layers{i}.distanceFcn to 'template_transfer'.

% Copyright 2005-2010 The MathWorks, Inc.

%% Boilerplate Code - Same for all Distance Functions

persistent INFO;
if (nargin < 1), nnerr.throw('Not enough arguments.'); end
if ischar(in1)
  switch in1
    case 'info',
      if isempty(INFO), INFO = get_info; end
      out1 = INFO;
    % NNET 6.0 Compatibility
    case 'name', info = get_info; out1 = info.name;
  end
else
  out1 = calculate_distances(in1);
end

%%
function info = get_info

% *** CUSTOMIZE HERE ***
% Replace the name string below, with a user friendly name for your
% function.

info.function = mfilename;
info.name = 'Template';
info.description = nnfcn.get_mhelp_title(mfilename);
info.type = 'nntype.distance_fcn';
info.version = 6.0;

%%
function d = calculate_distances(pos)

[rows,cols] = size(pos);
d = zeros(cols,cols);
for i=1:cols
  for j=1:(i-1)
    d(i,j) = calculate_distance(pos(:,i),pos(:,j));
  end
end
d = d + d';

%%
function d = calculate_distance(v1,v2)

% *** CUSTOMIZE HERE ***
% Replace the calculation below with your own distance calculation.
% *** Calculate scalar distance d between column vectors v1 and v2.

d = sqrt(sum(v1-v2).^2);
