classdef Frestoptions
%

% Class definition for @Frestoptions (the option set for frestimate)

% Author(s): Erman Korkut 10-Jun-2009
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/21 22:04:54 $
    
    properties
        UseParallel
        ParallelPathDependencies
        BlocksToHoldConstant = [];
    end
    
    methods
        % Constructor
        function obj = Frestoptions(varargin)
            % Set the default values
            obj.ParallelPathDependencies = {''};
            obj.UseParallel = scdgetpref('UseParallel');
            % Set the user defined properties
            for ct = 1:(nargin/2)
                obj.(varargin{2*ct-1}) = varargin{2*ct};
            end
        end
        % Display/disp method
        function display(this)
            disp(' ');
            if usejava('Swing') && desktop('-inuse') && feature('hotlinks')
                disp(ctrlMsgUtils.message('Slcontrol:frest:strFrestimateWithHelpLink'));
            else
                disp(ctrlMsgUtils.message('Slcontrol:frest:strFrestimate'));
            end
            fprintf('     UseParallel (on/off)    : %s\n',this.UseParallel);
            fprintf('     ParallelPathDependencies:');
            if isequal(this.ParallelPathDependencies,{''})
                fprintf(' {0x1 cell}\n');
            else
                disp(' ');
                for ct = 1:numel(this.ParallelPathDependencies)                    
                    fprintf('\t\t %s \n',this.ParallelPathDependencies{ct});
                end
            end
            fprintf('     BlocksToHoldConstant    :');
            if isempty(this.BlocksToHoldConstant)
                fprintf(' []\n');
            else
                fprintf(' [1x%d Simulink.BlockPath]\n',numel(this.BlocksToHoldConstant));                
            end                
            disp(' ');
        end
        % Set methods of properties for individual error checking
        function obj = set.UseParallel(obj,val)
            LocalCheckOnOff('UseParallel',val);
            obj.UseParallel = val;
        end
        function obj = set.ParallelPathDependencies(obj,val)
            if ~iscellstr(val)
                ctrlMsgUtils.error('Slcontrol:frest:InvalidParallelPathDependencies')
            end
            obj.ParallelPathDependencies = val;
        end
        function obj = set.BlocksToHoldConstant(obj,val)
            if isempty(val) || isa(val,'Simulink.BlockPath')
                obj.BlocksToHoldConstant = val;
            else
                ctrlMsgUtils.error('Slcontrol:frest:InvalidBlocksToHoldConstant');                
            end
        end
    end
    
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalCheckOnOff
%  Error check for on/off properties
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCheckOnOff(field, val)
if ~any(strcmp(val,{'on','off'}))
    ctrlMsgUtils.error('Slcontrol:frest:InvalidOnOffFrestoptions',field)
end
end

