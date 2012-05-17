function [success, exception] = validate(this)
%VALIDATE Validate settings of Dialog object
%
% stat: boolean status, 0=fail, 1=accept
% err: error message, string

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/12/07 20:45:10 $

mapExpression = this.dialog.getWidgetValue('MapExpression');
[success, exception, map] = validateMapExpression(this, mapExpression);

if success
    [success, exception] = validateMap(this, map);
end
if ~success
    return;
end
% Check that user ranges are valid
%
userRange = this.dialog.getWidgetValue('UserRange');
userRangeMin_str = this.dialog.getWidgetValue('UserRangeMin');
userRangeMax_str = this.dialog.getWidgetValue('UserRangeMax');

% Only test user range if ranges are enabled
if userRange
    % Convert string to double
    %
    userRangeMin = str2double(userRangeMin_str);
    userRangeMax = str2double(userRangeMax_str);

    % invalid entries produce NaN
    success = ~isnan(userRangeMin) && ~isnan(userRangeMax);
    if ~success
        [msg, id] = uiscopes.message('UserRangeNotNumeric');
        exception = MException(id, msg);
        return
    end
    success = isreal(userRangeMin) && isreal(userRangeMax) ...
        && ~issparse(userRangeMin) && ~issparse(userRangeMax);
    if ~success
        [msg, id] = uiscopes.message('UserRangeNotReal');
        exception = MException(id, msg);
        return;
    end
    % Check that scale min <= scale max
    % Only consider min/max scale factors if scaling is turned on
    success = (userRangeMin <= userRangeMax);
    if ~success
        [msg, id] = uiscopes.message('UserRangeMaximumLessThanMinimum');
        exception = MException(id, msg);
        return
    end

    % Test for out-of-range scale values
    success = (userRangeMin >= this.ScaleLimits(1)) && ...
              (userRangeMax <= this.ScaleLimits(2));
    if ~success
        [msg, id] = uiscopes.message('UserRangeNotInRange',...
                        this.ScaleLimits(1), this.ScaleLimits(2));
        exception = MException(id, msg);
        return
    end
end

% [EOF]
