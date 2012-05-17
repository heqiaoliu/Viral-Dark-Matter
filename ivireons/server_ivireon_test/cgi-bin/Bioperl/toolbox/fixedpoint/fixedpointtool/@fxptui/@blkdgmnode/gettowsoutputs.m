function signals = gettowsoutputs(h, varargin)
%GETTOWSOUTPUTS   Get the outputs assigned to MATLAB workspace

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/11/13 17:57:12 $

signals = initsignals(varargin{:});
switch h.daobject.SaveFormat
    case 'Array'
        signals = array2signals(h, signals);
    otherwise
        signals = struct2signals(h, signals);
end

%--------------------------------------------------------------------------
function signals = array2signals(h,signals)
wsvarnames = getoutputs(h);
outports = find(h.daobject, '-isa', 'Simulink.Outport', '-Depth', 1)'; %#ok<GTARG>
numvars = numel(wsvarnames);
numouts = numel(outports);
for i = 1:numel(outports)
    %data for each port is stored in a variable
    if(numvars == numouts)
        wsvarname = wsvarnames{i};
        idx = 1;
        %path = fxptds.getpath(outports(i).getFullName);
        %if this is one for and one variable process without indexing so
        %that multi dimensional data gets handles properly. only important
        %for arrays.
        if(numvars == 1)
            path = fxptds.getpath(outports.getFullName);
            try
                % This check is put in place to prevent cases where an m-file with the same name as the variable gets executed and returns an output that does not
                % make sense.The exist command returns 1 if it finds a variable in the base workspace with the name wsvarname.
                if (evalin('base',['exist(''' wsvarname ''',''var'')']) == 1)
                    wsdata = evalin('base', wsvarname);
                    signals = addsignals(h, signals, path, wsvarname, wsdata ,1);
                end
            catch fpt_exception %#ok<NASGU>
                % some variables might not exist in the base workspace.
                % Ignore error and continue.
            end
            break;
        end
        %data for all ports is stored in a single variable
    else
        wsvarname = wsvarnames{:};
        idx = i;
    end
    %path to the port
    path = fxptds.getpath(outports(i).getFullName);
    try
        % This check is put in place to prevent cases where an m-file with the same name as the variable gets executed and returns an output that does not
        % make sense.The exist command returns 1 if it finds a variable in the base workspace with the name wsvarname.
        if (evalin('base',['exist(''' wsvarname ''',''var'')']) == 1)
            wsdata = evalin('base', wsvarname);
            signals = addsignals(h, signals, path, wsvarname, wsdata(:,idx) ,1);
        end
    catch fpt_exception %#ok<NASGU>
        % some variables might not exist in the base workspace. Ignore
        % error and continue.
    end
end

%--------------------------------------------------------------------------
function signals = struct2signals(h,signals)
wsvarnames = getoutputs(h);
outports = find(h.daobject, '-isa', 'Simulink.Outport', '-Depth', 1)'; %#ok<GTARG>
for i = 1:numel(outports)
    %data for each port is stored in a variable
    if(numel(wsvarnames) == numel(outports))
        wsvarname = wsvarnames{i};
        try
            % This check is put in place to prevent cases where an m-file with the same name as the variable gets executed and returns an output that does not
            % make sense.The exist command returns 1 if it finds a variable in the base workspace with the name wsvarname.
            if (evalin('base',['exist(''' wsvarname ''',''var'')']) == 1)
                wsdata = evalin('base', wsvarname);
                %data for all ports is stored in a single variable
                %path to the port
                path = fxptds.getpath(outports(i).getFullName);
                signals = addsignals(h, signals, path, wsvarname, wsdata, 1);
            end
        catch fpt_exception %#ok<NASGU>
                            % some variables might not exist in the base workspace. Ignore
                            % error and continue.
        end
    else
        wsvarname = wsvarnames{:};
        try
            % This check is put in place to prevent cases where an m-file with the same name as the variable gets executed and returns an output that does not
            % make sense.The exist command returns 1 if it finds a variable in the base workspace with the name wsvarname.
            if (evalin('base',['exist(''' wsvarname ''',''var'')']) == 1)
                temp = evalin('base', wsvarname);
                wsdata.time = temp.time;
                wsdata.signals = temp.signals(i);
                %path to the port
                path = fxptds.getpath(outports(i).getFullName);
                signals = addsignals(h, signals, path, wsvarname, wsdata, 1);
            end
        catch fpt_exception %#ok<NASGU>
                            % some variables might not exist in the base workspace. Ignore
                            % error and continue.            
        end
    end
end

%--------------------------------------------------------------------------
function wsvarnames = getoutputs(h)
%convert from 'var1, var2, var3' format to cell
str = h.daobject.OutputSaveName;
wsvarnames = strread(str,'%s','delimiter',',');

% [EOF]
