function st = close(varargin)
%CLOSE  Close figure.
%   CLOSE(H) closes the window with handle H.
%   CLOSE, by itself, closes the current figure window.
%
%   CLOSE('name') closes the named window.
%
%   CLOSE ALL  closes all the open figure windows.
%   CLOSE ALL HIDDEN  closes hidden windows as well.
%
%   STATUS = CLOSE(...) returns 1 if the specified windows were closed
%   and 0 otherwise.
%
%   See also DELETE.

%   CLOSE ALL FORCE  unconditionally closes all windows by deleting them
%   without executing the close request function.
%
%   CLOSE ALL may be over-ridden by setting appdata on the figure to
%   'IgnoreCloseAll' with a value of 1.
%       setappdata(FIGH, 'IgnoreCloseAll', 1);
%
%   CLOSE ALL FORCE may be over-ridden by setting appdata on the figure to
%   'IgnoreCloseAll' with a value of 2. This over-rides CLOSE ALL as well.
%       setappdata(FIGH, 'IgnoreCloseAll', 2);

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.42.4.16 $  $Date: 2009/10/24 19:18:01 $

h = [];
closeAll = 0;
closeForce = 0;
closeHidden = 0;
status = 1;
nameRequested = 0;

% Input can be <handle>, '<handle>', 'force', and/or 'all' in any order
for i=1:nargin
    cur_arg = varargin{i};

    if ischar(cur_arg)
        switch lower(cur_arg)
            case 'force',
                closeForce  = 1;
            case 'all',
                closeAll    = 1;
            case 'hidden',
                closeHidden = 1;
            case 'gcf',
                h = [h gcf]; %#ok
            case 'gcbf',
                h = [h gcbf]; %#ok
            otherwise
                nameRequested = 1;
                %Find Figure with given name, or it is command style call
                hlist = findobj(get(0,'children'),'flat','name',cur_arg);
                if ~isempty(hlist)
                    h = [h hlist]; %#ok
                else
                    num = str2double(cur_arg);
                    if ~isnan(num)
                        h = [h num]; %#ok
                    end
                end
        end
    else
        h = [h cur_arg]; %#ok
        if isempty(h),  % make sure close([]) does nothing:
            if nargout==1
                st = status;
            end
            return
        end
    end
end

% If h is empty that this point, define it by context.
if isempty(h)
    % If a name was requested and we didn't find
    % a figure handle, error out
    if nameRequested
        error('MATLAB:close:WindowNotFound', 'Specified window does not exist.');
    end

    h = safegetchildren(closeForce, closeAll, closeHidden);
end

if (isa(h, 'ui.figure'))
    % Convert GBT1.5 figure to a double.
    h = double(h);
end

if ~checkfigs(h)
    error('MATLAB:close:InvalidFigureHandle', 'Invalid figure handle.'); 
end

if closeForce
    delete(h)
else
    status = request_close(h);
end

if nargout==1
    st = status;
end

%------------------------------------------------
function status = request_close_helper(h,pre_or_post)
% When called with a valid figure handle and the flag 'pre', this stores
% current figure and current state of hidden handles in persistent variables
% for easy restoration.
% When called with any 1st input and the flag 'post', this restores
% current figure and the state of hidden handles.
% If called with the flag 'pre' twice without an intervening call with flag
% 'post', a warning is thrown, the passed in handle is deleted, and status
% returned is false.

persistent closeVisitedHandles;
persistent old_shh;

switch pre_or_post
 case 'pre'
  % prevent recursion
  if ismember(h, closeVisitedHandles)
      % Throw the warning. Allow users to turn off the warning using the ID.
      warning('MATLAB:Figure:RecursionOnClose', ...
              'A callback recursively calls CLOSE.  Use DELETE to prevent this message.');
      delete(h)
      status = false;
      return;
  end

  if ~checkfigs(h)
      error('MATLAB:close:assert','Unexpected invalid handle passed to request_close_helper')
  end

  old_shh{end+1} = get(0,'ShowHiddenHandles');
  set(0,'ShowHiddenHandles', 'on')
  set(0,'CurrentFigure', h)
  closeVisitedHandles = [closeVisitedHandles, h];
  status = true;
 case 'post'
  % we don't want to restore gcf here as the CloseRequestFcn
  % may have changed it on purpose
  set(0,'ShowHiddenHandles', old_shh{end})
  old_shh(end) = [];
  closeVisitedHandles(closeVisitedHandles==h) = [];
  status = true;
 otherwise
  error('MATLAB:close:assert','Unexpected value passed to request_close_helper')
end

%------------------------------------------------
function status = request_close(h)
% return 1 if requested handles were closed.
% return 0 if any of the requested handles were not closed.
% throw an error if calling the CloseRequestFcn on any of the
%   requested handles throws an error.
% throw a warning and delete the requested handle if calling
%   the CloseRequestFcn on any of the requested handles calls
%   back into close.
% make the figure the current figure and turn ShowHiddenHandles
%   on before calling the CloseRequestFcn on handle.
result = 1;
status = 1;
for lp = 1:length(h)
    figh = h(lp);
    if ~ishghandle(figh)
        continue;
    end

    doubleH = double(figh);
    if (request_close_helper(doubleH,'pre'))
            
        try
            hgclose(figh);
        catch ex
            result = 0;
            %cause = MException(ex.identifier,ex.message);
            exToThrow = MException('MATLAB:UndefinedFunction','Error while evaluating figure CloseRequestFcn');
            ex = ex.addCause(exToThrow);
        end
        request_close_helper(doubleH,'post');

        if ~result
            throw(ex);
        end

        if ishghandle(figh)
            status = 0;
        end
    end
end

%------------------------------------------------
function status = checkfigs(h)
% if any of the passed in handles are invalid or not figure handles, return false
status = true;
for i=1:length(h)
    if ~any(ishghandle(h(i),'figure'))
        status = false;
        return
    end
end

%------------------------------------------------
function h = safegetchildren(closeForce, closeAll, closeHidden)
% find all the figure children off root and filter out handles that
% based on application data or handle visibility.
if closeHidden || closeForce
    h = allchild(0);
    if ~closeAll && ~isempty(h)
        h = h(1);
    end
elseif closeAll
    h = get(0,'Children');
else
    h = get(0,'CurrentFigure');
end
if isempty(h)
    return;
end

specialTags = {
    'SFCHART', ...
    'DEFAULT_SFCHART', ...
    'SFEXPLR', ...
    'SF_DEBUGGER', ...
    'SF_SAFEHOUSE', ...
    'SF_SNR', ...
    'SIMULINK_SIMSCOPE_FIGURE'
    };
filterFigs = [];
for j = 1:length(specialTags)
    filterFigs = [filterFigs; findobj(h,'flat','tag',specialTags{j})]; %#ok
end
h = local_setdiff(h,filterFigs);

% If any of these figs have IgnoreCloseAll set to 1, they would
% override closeAll only. If it is set to 2, they would override
% closeAll and closeForce.

% IgnoreCloseAll  []      1        2
% closeAll      close   filter   filter
% closeHidden   close   filter   filter
% closeForce    close   close    filter
filterFigs = [];
for i =1:length(h)
    if ~isappdata(h(i), 'IgnoreCloseAll');
        continue;
    end
    ignoreFlag = getappdata(h(i), 'IgnoreCloseAll');
    if isempty(ignoreFlag) || ~isscalar(ignoreFlag) || ~isnumeric(ignoreFlag)
        warning('MATLAB:close','Unrecognized value for IgnoreCloseAll - valid values are 1 or 2')
        continue;
    end
    switch ignoreFlag
        case 2
            filterFigs = [filterFigs; h(i)]; %#ok
        case 1
            if ~closeForce
                filterFigs = [filterFigs; h(i)]; %#ok
            end
        otherwise
            warning('MATLAB:close','Unrecognized value for IgnoreCloseAll - valid values are 1 or 2')
            % do nothing - unrecognized app data
    end
end
h = local_setdiff(h,filterFigs);

%------------------------------------------------
% Local version of setdiff that manually walks through and diffs
% a vector of handles. This should be removed if/when setdiff
% is natively supported by MCOS.
function result = local_setdiff(hv1, hv2)
% Return the vector of handles for hv1 that do not exist in hv2.
% Return [] is hv1 is [].
% Return hv1 is hv2 is [].

%%%%%%%%%%%%%%%%%%
% Setdiff used to return a numeric-ordered list of handles, which in turn
% determined the order in which figures are closed. There is code that 
% depends on this order - like colormapeditor!!!
%%%%%%%%%%%%%%%%%%
result = hv1;
if (feature('HGUsingMATLABClasses') == 1)
    if ~isempty(hv1)
        for i=1:length(hv2)
            diffmask = (handle(hv1) == handle(hv2(i)));
            
            result = result(~diffmask);
        end
    end
else
    result = setdiff(double(hv1), double(hv2));
end

