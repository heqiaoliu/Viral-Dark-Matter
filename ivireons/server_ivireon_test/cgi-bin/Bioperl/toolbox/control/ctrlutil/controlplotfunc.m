function varargout = controlplotfunc(fname,inputvals)
%PLOTPICKERFUNC  Support function for Plot Picker component.

% Copyright 2009 The MathWorks, Inc.

% Default display functions for stats plots

n = length(inputvals);
toshow = false;
switch lower(fname)
    case {'bodeplot','nicholsplot','nyquistplot','sigmaplot'}
        if n==1
            sys = inputvals{1};
            toshow = isa(sys,'lti');
        elseif n>=2
            for k=1:length(inputvals)-1
                if ~isa(inputvals{k},'lti')
                    varargout{1} = false;
                    return;
                end
            end
            lastarg = inputvals{end};
            toshow = isa(lastarg,'lti') || ...
                (iscell(lastarg) && length(lastarg)==2 && isnumeric(lastarg{1}) && ...
                isscalar(lastarg{1}) && isnumeric(lastarg{2}) && isscalar(lastarg{2}) && ...
                lastarg{2}>lastarg{1}) || ...
                (isnumeric(lastarg) && isvector(lastarg));
        end
    case 'rlocusplot' 
        if n==1
            sys = inputvals{1};
            toshow = isa(sys,'lti');
        elseif n>=2
            for k=1:length(inputvals)-1
                if ~isa(inputvals{k},'lti')
                    varargout{1} = false;
                    return;
                end
            end
            lastarg = inputvals{end};
            toshow = isa(lastarg,'lti') || ...
                (isnumeric(lastarg) && isvector(lastarg));
        end          
    case {'pzplot','iopzplot'}
        if n>=1
            for k=1:length(inputvals)
                if ~isa(inputvals{k},'lti')
                    varargout{1} = false;
                    return;
                end
            end
            toshow = true;
        end  
    case {'stepplot','impulseplot'}
        if n==1
            sys = inputvals{1};
            toshow = isa(sys,'lti');
        elseif n>=2
            for k=1:length(inputvals)-1
                if ~isa(inputvals{k},'lti')
                    varargout{1} = false;
                    return;
                end
            end
            lastarg = inputvals{end};
            toshow = isa(lastarg,'lti') || ...
                (isnumeric(lastarg) && isvector(lastarg));
        end 
    case 'hsvplot'
        if n==1
            sys = inputvals{1};
            toshow = isa(sys,'lti');
        end  
end
varargout{1} = toshow;
