function varargout = filterplotfunc(action,fname,inputnames,inputvals)
%PLOTPICKERFUNC  Support function for Plot Picker component.

% Copyright 2009 The MathWorks, Inc.

% Default display functions for MATLAB plots
if strcmp(action,'defaultshow')
    n = length(inputvals);
    toshow = false;
    % A single empty should always return false
    if isempty(inputvals) ||  isempty(inputvals{1})
        varargout{1} = false;
        return
    end
    switch lower(fname)
        % Either one or more dfilt objects or one or more numerator-denominator
        % pairs.
        case {'fdtfvtoolmag','fdtfvtoolphase','fdtfvtoolmagphase','fdtfvtoolgrpdelay',...
                'fdtfvtoolphdelay','fdtfvtoolimpulse','fdtfvtoolstep','fdtfvtoolpolezero',...
                'fdtfvtoolfiltcoef','fdtfvtoolfiltinfo'} 
            x = inputvals{1};
            if n==1 
                toshow = localFilterDesignObject(x);             
            else
                toshow = all(cellfun(@(x) localFilterDesignObject(x),inputvals));
            end
        case {'fdtfvtoolmagestimate','fdtfvtoolnoisepower'}
            x = inputvals{1};
            if n==1 
                toshow = localNonAdaptOrMultiRateFilter(x);
            else
                toshow = all(cellfun(@(x) localNonAdaptOrMultiRateFilter(x),inputvals));
            end            
        case 'fdtzerophase'
            if n==1 
                x = inputvals{1};
                toshow = isa(x,'adaptfilt.baseclass') || ...
                    isa(x,'mfilt.abstractmultirate');
            else
                toshow = all(cellfun(@(x) (isa(x,'adaptfilt.baseclass') || ...
                    isa(x,'mfilt.abstractmultirate')),...
                    inputvals));
            end           
            
      case 'polyphase'
            x = inputvals{1};
            if n==1
                toshow = isa(x,'mfilt.abstractmultirate');
            end
    end
    varargout{1} = toshow;
elseif strcmp(action,'defaultdisplay')
    dispStr = '';
    switch lower(fname)
        case 'fdtfvtoolmag'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''magnitude'');figure(gcf)'];
        case 'fdtfvtoolphase' 
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''phase'');figure(gcf)']; 
        case 'fdtfvtoolmagphase'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''freq'');figure(gcf)'];   
        case 'fdtfvtoolgrpdelay'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''grpdelay'');figure(gcf)'];
        case 'fdtfvtoolphdelay'
             inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''phasedelay'');figure(gcf)'];           
        case 'fdtfvtoolimpulse'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''impulse'');figure(gcf)']; 
        case 'fdtfvtoolstep'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''step'');figure(gcf)'];
        case 'fdtfvtoolpolezero'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''polezero'');figure(gcf)'];
        case 'fdtfvtoolfiltcoef'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''coefficients'');figure(gcf)'];
        case 'fdtfvtoolfiltinfo'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''info'');figure(gcf)']; 
        case 'fdtfvtoolmagestimate'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''magestimate'');figure(gcf)']; 
        case 'fdtfvtoolnoisepower'
            inputNameArray = [inputnames(:)';repmat({','},1,length(inputnames))]; 
            dispStr = ['fvtool(' inputNameArray{:} '''Analysis'',''noisepower'');figure(gcf)']; 
    end
    varargout{1} = dispStr;   
end

function status = localFilterDesignObject(this)

status = isa(this,'adaptfilt.apru') || isa(this,'adaptfilt.bap') || ...
         isa(this,'aadaptfilt.adaptfilt') || isa(this,'adaptfilt.adaptdffir') || ...
         isa(this,'mfilt.abstractfirmultirate') || isa(this,'mfilt.abstractcic');
                
function status = localNonAdaptOrMultiRateFilter(this)
  
% Indicate if this is a dfilt filter which is not either an adaptive or a
% multirate filter.
status = isa(this,'dfilt.basefilter') && ~isa(this,'mfilt.abstractmultirate') && ...
          ~isa(this,'adaptfilt.baseclass');