classdef SimulationOutput
%SIMULINK.SIMULATIONOUTPUT object contains all of the simulation output.
%   All outputs from a simulation, including the workspace variables, are 
%   packaged into a single Simulink.SimulationOutput object and returned.
%   To access the data contained within this object, use the GET method with
%   a specific variable name. All of the data variable names associated with
%   the object can be identified using the WHO method.
%
%   %Example
%       simOut = sim('vdp','SimulationMode','rapid','AbsTol','1e-5',...
%                    'SaveState','on','StateSaveName','xoutNew',...
%                    'SaveOutput','on','OutputSaveName','youtNew');
%       simOutVars = simOut.who
%       yout = simOut.get('youtNew')
%       yout = simOut.find('youtNew')
%
%   Simulink.SimulationOutput methods:
%      GET  : returns the value of variable of a given name
%      FIND : finds the value of variable of a given name
%      WHO  : lists the names of the data variables associated with an object
%   See also SIM

%   Copyright 2009-2010 The MathWorks, Inc.
properties (SetAccess = private, GetAccess = private)
    Data
end

methods(Hidden = true)
        function out = SimulationOutput(varargin)
        if nargin == 1
            out.Data  = varargin{1};
        else
            out.Data = struct;
        end
        end
end
    
methods(Access = public)
        function out = who(simOut)
        varNames = sort(fieldnames(simOut.Data));
        if nargout > 0
            out = varNames;
        else
            if isempty(varNames)
                disp(DAStudio.message(...
                    'Simulink:tools:SimulationOutputWhoEmpty'));
            else
                disp(DAStudio.message(...
                    'Simulink:tools:SimulationOutputWhoHeading'));
                fprintf(1, '\n');
                varStr = '    ';
                for i=1:length(varNames)
                    varStr = [varStr, sprintf('%s    ', varNames{i})]; %#ok
                end
                disp(varStr);
            end
            fprintf(1, '\n');
        end
        end % who
    
    
% In future we don't expect the get method to change
        function out = get(simOut, var)
        if nargin == 2
            if isfield(simOut.Data, var)
                out = simOut.Data.(var);
            else
                out = [];
            end
        else
            out = who(simOut);
        end
        end % get
    
% The find method in future will actually perform a search
        function out = find(simOut, var)
        if nargin == 2
            if isfield(simOut.Data, var)
                out = simOut.Data.(var);
            else
                out = [];
            end
        else
            out = who(simOut);
        end
        end % find
        
end % methods


methods(Hidden = true)
        function varargout = properties(simOut)
            [varargout{1:nargout}] = who(simOut);
            end
        
            function display(simOut)
            fprintf(1, '\n');
            if (length(simOut) > 1)
                disp([sizeStr(size(simOut)), ' ', ...
                      DAStudio.message(...
                          'Simulink:tools:SimulationOutputArrDispHeading')]);
                fprintf(1, '\n');
            else
                disp(DAStudio.message(...
                    'Simulink:tools:SimulationOutputDispHeading'));
                fprintf(1, '\n');
                if ~isempty(fieldnames(simOut.Data))
                    disp(simOut.Data);
                else
                    disp(DAStudio.message(...
                        'Simulink:tools:SimulationOutputDispEmpty'));
                end
            end
            fprintf(1, '\n');
            end
        
        
end % methods
end % classdef


function szStr = sizeStr(sz)
szStr = '';
for i=1:length(sz)-1
    szStr = [szStr, num2str(sz(i)), 'x']; %#ok
end
szStr = [szStr, num2str(sz(i+1))];
end
