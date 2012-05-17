function extraArgs = parseSfiUfiInputs(varargin)
% Parse the extra inputs (val is required) to the sfi & ufi contructors

%   Copyright 2008 The MathWorks, Inc.

nVar = length(varargin);
extraArgs = varargin;
switch nVar
    case {1,2,3} 
        % sfi(val,wordLength) OR sfi(sfi(val,wordLength,farctionLength)
        % OR sfi(val,wordLength,Slope,Bias)
        for idx = 1:nVar
            unUsedFlag = assertIsNumericArg(varargin{idx}); %#ok
        end
    case 4 
        % sfi(val,wordLength,slopeAdjustmentFactor,fixedExp,Bias)
        for idx = [1,3,4]
            unUsedFlag = assertIsNumericArg(varargin{idx}); %#ok
        end
        unusedFlag = validateSlopeAdjustmentFactor(varargin{2}); %#ok
end
        
%--------------------------------------------------------------------------        
% function extraArgs = parseInputs(varargin)
% % Parse the inputs using the inputParser class
% 
% % xxx I am not sure I like the way the error message is displyed:
% % xxx ??? Error using ==> sfi>parseInputs at 33 >> THIS LINE ESPECIALLY
% % xxx Argument 'saf' failed validation with error: >> THIS LINE ESPECIALLY
% % xxx Invalid SlopeAdjustmentFactor specified; >> WOULD JUST LIKE THIS
% % xxx the SlopeAdjustmentFactor must be greater than or equal to 1 and less than 2.
% 
% nVar = length(varargin);
% p = inputParser;
% switch nVar
%     case 1
%         p.addRequired('wordLength',@assertIsNumericArg);
%     case 2
%         p.addRequired('wordLength',@assertIsNumericArg);
%         p.addRequired('fractionLength',@assertIsNumericArg);
%     case 3
%         p.addRequired('wordLength',@assertIsNumericArg);
%         p.addRequired('slope',@assertIsNumericArg);
%         p.addRequired('bias',@assertIsNumericArg);
%     case 4
%         p.addRequired('wordLength',@assertIsNumericArg);
%         p.addRequired('saf',@validateSlopeAdjustmentFactor);
%         p.addRequired('fixexp',@assertIsNumericArg);
%         p.addRequired('bias',@assertIsNumericArg);
% end
% p.parse(varargin{:});
% extraArgs = struct2cell(p.Results)';

%--------------------------------------------------------------------------
function argVal = assertIsNumericArg(u)
% Validate that the input u is numeric

argVal = u;
if ~isnumeric(u)
        error('fi:constructor:invalidInput','Input must be numeric.');
end
%--------------------------------------------------------------------------
function flag = validateSlopeAdjustmentFactor(saf)
% Validate that the slope adjustment factor is between 1 & 2

flag = assertIsNumericArg(saf);
if saf<1.0 || saf >=2.0
    error('fi:constructor:InvalidSetting',...
        'Invalid SlopeAdjustmentFactor specified; the SlopeAdjustmentFactor must be greater than or equal to 1 and less than 2.');
end
%--------------------------------------------------------------------------
