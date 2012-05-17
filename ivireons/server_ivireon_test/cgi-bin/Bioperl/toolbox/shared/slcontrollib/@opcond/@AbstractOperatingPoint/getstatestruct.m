function xstruct = getstatestruct(this) 
%

% GETSTATESTRUCT Extract the state structure from an operating point
%
%   XSTRUCT = GETSTATESTRUCT(OP_POINT) extracts a structure of state values, 
%   X, from the operating point object, OP_POINT. 
%
%   See also OPERPOINT, OPERSPEC.

% Author(s): John W. Glass 17-Feb-2005
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/06/13 15:28:28 $

% Get the states in the operating point object
states = this.States;

if numel(states) == 0
    % Don't do anything
    xstruct = [];
    return
end
                            
% Create a skeleton structure
xstruct = struct('time',this.time,'signals',[]);

% The model must be compiled if the sample times were not previously set
if any(cellfun('isempty',get(this.States,{'Ts'})))
    modelcompiled = true;
    feval(this.model,[],[],[],'compile');
else
    modelcompiled = false;
end

% Now fill in the rest of the states
for ct = numel(states):-1:1
    tsvalues = get(states(ct),'Ts');
    % Get the sample time type from the run time object if it is not known
    if isempty(tsvalues)
        r = get_param(states(ct).Block,'RunTimeObject');
        % If there is more then one sample time then error out that this is
        % not consistent.
        if size(r.SampleTimes,1) > 1
            ctrlMsgUtils.error('SLControllib:opcond:OperatingPointNeedsUpdate',this.Model)
        else
            if r.NumContStates
                tslabel = 'CSTATE';
            else
                tslabel = 'DSTATE';
            end
            tsvalues = r.SampleTimes;
        end
    else
        tslabel = states(ct).SampleType;
    end
    % Create the state structure.  States should be in a column vector
    xsignal(ct) = struct('values', reshape(states(ct).x,1,states(ct).Nx),...
                         'dimensions',states(ct).Nx,...
                         'label',tslabel,...
                         'blockName',states(ct).Block,...
                         'stateName',states(ct).StateName,...
                         'inReferencedModel', states(ct).inReferencedModel,...
                         'sampleTime',tsvalues);
end

if modelcompiled
    feval(this.Model,[],[],[],'term');
end

% Fill in the top structure
xstruct.signals = xsignal;
