function out1 = gridtop(varargin)
%GRIDTOP Grid layer topology function.
%
%  <a href="matlab:doc gridtop">gridtop</a> calculates neuron positions for layers whose
%  neurons are arranged in an N dimensional grid.
%
%  <a href="matlab:doc gridtop">gridtop</a>(DIM1,DIM2,...,DIMN) takes N positive integer arguments
%  and returns and NxS matrix of N coordinate vectors, where S is
%  the product of DIM1*DIM2*...*DIMN.
%
%  Here positions are created with this function and plotted.
%
%    positions = <a href="matlab:doc gridtop">gridtop</a>(8,5);
%    <a href="matlab:doc plotsompos">plotsompos</a>(positions)
%
%  See also HEXTOP, RANDTOP.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.9 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Topology Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin < 1), nnerr.throw('Not enough arguments.'); end
  in1 = varargin{1};
  if ischar(in1)
    switch in1
      case 'info',
        out1 = INFO;
      case 'check_param'
        out1 = '';
      otherwise,
        % Quick info field access
        try
          out1 = eval(['INFO.' in1]);
        catch %#ok<CTCH>
          nnerr.throw(['Unrecognized argument: ''' in1 ''''])
        end
    end
  else
    out1 = calculate_positions(varargin{:});
  end
end

function v = fcnversion
  v = 7;
end

%  BOILERPLATE_END
%% =======================================================

%%
function info = get_info
 info = nnfcnTopology(mfilename,'Grid',fcnversion,4);
end

function pos = calculate_positions(varargin)
  dim = [varargin{:}];

  size = prod(dim);
  dims = length(dim);
  pos = zeros(dims,size);

  len = 1;
  pos(1,1) = 0;
  for i=1:length(dim)
    dimi = dim(i);
    newlen = len*dimi;
    pos(1:(i-1),1:newlen) = pos(1:(i-1),rem(0:(newlen-1),len)+1);
    posi = 0:(dimi-1);
    pos(i,1:newlen) = posi(floor((0:(newlen-1))/len)+1);
    len = newlen;
  end
end
