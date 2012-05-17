function obj = frestimateOptions(varargin)
% FRESTIMATEOPTIONS  Set options for frequency response estimation
%
% OPT=FRESTIMATEOPTIONS creates a frequency response estimation options object
% with the default settings. The variable, OPT, is passed to the function
% FRESTIMATE to specify options for frequency response estimation.
%
% OPT=FRESTIMATEOPTIONS('Property1','Value1','Property2','Value2',...) creates a 
% frequency response estimation options object, OPT, in which the option
% given by Property1 is set to the value given in Value1, the option given
% by Property2 is set to the value given in Value2, etc.
% 
% The following options can be set with FRESTIMATEOPTIONS:
%
%   UseParallel - Set to 'on' (default is 'off') to enable use of
%   matlabpool in FRESTIMATE command which will make use of parallel
%   computing.
%
%   ParallelPathDependencies - A cell array of strings which specify the
%   path dependencies to execute the model whose frequency response will be
%   estimated. Note that the folders listed in path dependencies must be
%   accessible by all the workers in the MATLAB pool.
%
%   BlocksToHoldConstant - An array of Simulink.BlockPath objects to
%   specify the blocks whose output should be held constant during the
%   simulation(s) that FRESTIMATE command performs to avoid interfering
%   with the analysis.
%
%   See also frestimate

% Author(s): Erman Korkut 10-Jun-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/05/10 17:56:08 $

obj = frest.Frestoptions(varargin{:});