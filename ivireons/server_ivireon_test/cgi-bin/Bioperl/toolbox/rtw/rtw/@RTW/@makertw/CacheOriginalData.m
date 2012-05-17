function CacheOriginalData(h)
%   CACHEORIGINALDATA is the method caches original data before starting 
%   make_rtw process.
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/10/06 14:00:18 $

% save the current MATLAB path, so that we can add the pwd, and then restore it
% when the build is done.
h.PathToRestore = path;
addpath(pwd);

% cache the original recycle state, and turn recycling off for the build
h.OrigRecycleState = recycle('off');

if strcmp(get_param(h.ModelHandle, 'Lock'), 'on'),
  % need to unlock the model so that the set_params in the code below will
  % work
  h.cleanChange('parameter', 'Lock','off');
end

%
%  Should not cache following values.
%
%Cache the original RTW options  
%  h.OrigRTWOptions  = get_param(h.ModelHandle,'RTWOptions');
%Cache the original RTW InlineParameters setting
%  h.OrigRTWInlineParameters  = get_param(h.ModelHandle,'RTWInlineParameters');
