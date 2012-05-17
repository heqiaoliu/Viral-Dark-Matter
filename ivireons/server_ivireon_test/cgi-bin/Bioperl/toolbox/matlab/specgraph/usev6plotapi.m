function [res,args]=usev6plotapi(varargin)
% This undocumented function may be removed in a future release

%USEV6PLOTAPI determine plotting version
%  [V6,ARGS] = USEV6PLOTAPI(ARG1,ARG2,...) checks to see if the V6-compatible
%  plotting API should be used and return true or false in V6 and any
%  remaining arguments in ARGS.

%  If Handle Graphics uses MATLAB classes
%      we determine plotting version with usev6plotapiHGUsingMATLABClasses.
%  Otherwise we determine plotting version as before:
%
%  if ARG1 is 'v6' the strip it off and return true
%  if ARG1 is 'group' the strip it off and return false
%  else return true
%  if ARG1 is 'defaultv6', then strip it off and return true
%  unless ARG2 is 'group', then strip it off too and return false.

%   Copyright 1984-2008 The MathWorks, Inc.

% First we check whether Handle Graphics uses MATLAB classes
isHGUsingMATLABClasses = feature('HGUsingMATLABClasses');

if (isHGUsingMATLABClasses)
    [res,args] = usev6plotapiHGUsingMATLABClasses(varargin{:});
else
    % defaults
    res = ~isempty(getappdata(0,'UseV6PlotAPI'));
    args = varargin;
    narg = nargin;
    filename = '';
    
    % strip off mfilename arguments if necessary.
    if (narg>1 && isa(args{end-1},'char')) && ...
            strcmp(args{end-1},'-mfilename') && ...
            isa(args{end},'char')
        filename = args{end};
        args = {args{1:end-2}};
        narg = narg-2;
    end
    
    % Parse the remaining arguments
    if narg>0 && isa(args{1},'char')
        if strcmp(args{1},'group')
            res = false;
            args = {args{2:end}};
        elseif strcmp(args{1},'v6')
            res = true;
            args = {args{2:end}};
            warnv6args(filename);
        elseif strcmp(args{1},'defaultv6')
            if narg>1 && isa(args{2},'char')
                if strcmp(args{2},'group')
                    res = false;
                    args = {args{3:end}};
                elseif strcmp(args{2},'v6')
                    res = true;
                    args = {args{3:end}};
                    warnv6args(filename);
                else
                    res = true;
                    args = {args{2:end}};
                end
            else
                res = true;
                args = {args{2:end}};
            end
        elseif (narg == 1) && strcmp(args{1},'on')
            if isempty(getappdata(0,'UseV6PlotAPI'))
                warning('MATLAB:usev6plotapi',...
                    ['You have enabled V6 compatibility mode for graphics. ' ...
                    'This option will be removed in a future version of MATLAB.'])
                setappdata(0,'UseV6PlotAPI','on');
            end
        elseif (narg == 1) && strcmp(args{1},'off')
            if isappdata(0,'UseV6PlotAPI')
                rmappdata(0,'UseV6PlotAPI');
            end
        end
    end
end

%--------------------------------------------------------------------%
function warnv6args(filename)
if isempty(filename)
    warning(['MATLAB:', lower(mfilename), ':DeprecatedV6Argument'],...
        ['The ''v6'' argument is deprecated,',...
        ' and will no longer be supported in a future release.']);
else
    warning(['MATLAB:', lower(filename), ':DeprecatedV6Argument'],...
        ['The ''v6'' argument to %s is deprecated,',...
        ' and will no longer be supported in a future release.'], upper(filename));
end
