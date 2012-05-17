function y = seq2con(x)
%SEQ2CON Convert sequential vectors to concurrent vectors.
%
%  The neural network toolbox represents concurrent vectors as matrix
%  columns and timesteps as cell array columns.
%
%  <a href="matlab:doc seq2con">seq2con</a>(X) takes neural network cell data X and convertes the cell
%  columns to matrix columns.
%
%  Here three sequential values are converted to concurrent values.
%
%    x1 = {1 4 2}
%    x2 = <a href="matlab:doc seq2con">seq2con</a>(x1)
%
%  Here two sequences of vectors over three time steps are converted
%  to concurrent vectors.
%
%    x1 = {[1; 1] [5; 4] [1; 2]; [3; 9] [4; 1] [9; 8]}
%    x2 = <a href="matlab:doc seq2con">seq2con</a>(x1)
%
%  See also CON2SEQ, CONCUR.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2010/04/24 18:08:39 $

if nargin < 1, nnerr.throw('Not enough input arguments.'); end
x = nntype.cell_data('format',x,'Data');
y = nnfast.seq2con(x);

