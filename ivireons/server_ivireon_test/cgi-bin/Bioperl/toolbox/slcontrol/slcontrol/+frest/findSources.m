function blks = findSources(model,varargin)
% FINDSOURCES finds the time-varying source blocks that can potentially
% interfere with the analysis performed with FRESTIMATE command
%
%   BLKS = frest.findSources('mdl') takes a Simulink model name, 'mdl', as
%   the input and returns all the time-varying source blocks, BLKS, whose
%   impact reaches to the output linearization points currently marked on the
%   model 'mdl', thus can potentially interfere with the analysis performed
%   by FRESTIMATE command. The output BLKS is an array of
%   Simulink.BlockPath objects.
%
%   BLKS = frest.findSources('mdl',IO) takes a Simulink model name, 'mdl',
%   and an array of linearization I/O points, IO and returns 
%   returns all the time-varying source blocks, 'blks', whose impact
%   reaches to the output linearization points that are specified in IO.
%
%
%   See also frestimateOptions, frestimate

%  Author(s): Erman Korkut 01-Mar-2010
%  Revised:
%  Copyright 2003-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2010/04/21 22:04:53 $

% Error checking
% Check number of input & output arguments
error(nargchk(1,2,nargin));
error(nargoutchk(0,1,nargout));
% Call the utility to find those blocks
linutil = slcontrol.Utilities;
if nargin > 1
    blks = findTimeVaryingSources(linutil,model,varargin{:});
else
    blks = findTimeVaryingSources(linutil,model);
end



