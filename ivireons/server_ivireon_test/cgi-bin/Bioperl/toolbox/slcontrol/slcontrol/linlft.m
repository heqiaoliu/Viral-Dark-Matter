function sys = linlft(varargin) 
% LINLFT Obtains a linear model from a Simulink model while removing
% specified Simulink blocks.
%
%   SYS = LINLFT('sys',IO,BLOCKS) takes a Simulink model name, 'sys' and
%   returns a linear model with user defined blocks removed from the
%   linearization.  The optional argument IO specifies the linearization
%   points.  The blocks removed are specified in a cell array of strings
%   BLOCKS specifying the full block path to the block being removed.
%   The resulting linear model LIN will be in the form:
%
%                  -------------
%             In-->|           |--> Out
%    Block 1 Out-->|           |--> Block 1 In
%    Block 2 Out-->|    SYS    |--> Block 2 In
%               ...|           |...
%    Block n Out-->|           |--> Block n In
%                  -------------
%
%   The top channels In and Out correspond to the linearization points
%   specified in IO and the remaining channels correspond to the connection
%   to the blocks that have been removed.
%
%   The overall linearization with the blocks reconnected with new
%   linearizations can be computed using LINLFTFOLD.
%
%   LINLFT is supported for all other variations of the input
%   arguments for LINEARIZE when using the 'block-by-block' linearization
%   algorithm specified in LINOPTIONS.
%
%   See also LINLFTFOLD, LINEARIZE, LINIO, GETLINIO, OPERPOINT.

% Author(s): John W. Glass 15-Oct-2008
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2010/04/21 22:04:51 $

blocksfound = false;
for ct = 1:nargin
    % Check for the block list.  Protect against the case where the user
    % would like to specify the state order.
    if isa(varargin{ct},'cell') && (~ischar(varargin{ct-1}) || ...
                    ~strcmp(varargin{ct-1},'StateOrder'))
        st = varargin{ct};
        nblks = numel(st);
        Factors = struct('Name',st,...
            'Value',[]);
        for ct_blk = 1:nblks
            rep = struct(...
                'Specification',1,...
                'Type','Expression',...
                'ParameterNames','',...
                'ParameterValues','');
            Factors(ct_blk).Value = rep;
        end
        varargin{ct} = Factors;
        blocksfound = true;
    end    
end

if ~blocksfound
    ctrlMsgUtils.error('Slcontrol:linearize:ErrorBlocksNotSpecifiedAsCell')
end

sys = linearize(varargin{:},'FoldFactors',false);