function sys = linlftfold(upper_lft,BlockSubs,varargin)
% LINLFTFOLD Folds specified block linearizations into a linearized 
% model.
%
%   LIN = LINLFTFOLD(LINDATA,BLOCKSUBS) takes a linear model LINDATA
%   computed using LINLFT and returns a linear model which folds in block
%   linearizations specified in BLOCKSUBS.  The block linearizations are
%   specified in a structure array BLOCKSUBS containing the following
%   fields:
%        	 Name: The name of the block being substituted.
%           Value: The value of the linearization.
%
%   See also LINLFT, LINEARIZE, LINIO, GETLINIO, OPERPOINT. 

% Author(s): John W. Glass 15-Oct-2008
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/07/09 20:55:18 $

if numel(varargin) == 1
    opt = varargin{1};
else
    opt = linoptions;
end

% Factorize blocks into a data structure format for utFoldBlockFactors
BlockFactors = utComputeBlockFactors(linutil,upper_lft.Ts,BlockSubs);

% Compute the linearization with the blocks folded.
sys = utFoldBlockFactors(linutil,upper_lft,BlockFactors,opt);