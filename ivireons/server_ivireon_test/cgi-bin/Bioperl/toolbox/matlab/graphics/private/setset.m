function setset( h, propName, propValue )
%SETSET Call SET on a Handle Graphics object or SET_PARAM on a Simulink object.
%   SETSET(H, NAME, VALUE ) SET property pair for Handle Graphics object H.
%   SETSET(H, NAME, VALUE ) SET_PARAM property pair for Simulink object H.
%   SETSET(N, NAME, VALUE ) SET_PARAM property pair on Simulink object named N.
%   For Simulink models SETSET ignores Lock settings.
%
%   See also SET, SET_PARAM.

%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $

if isempty(h)
  return
end

if ischar(h)
  h = get_param(h,'handle');
end

%
% Tease out the HG handles and Simulink handles
% from the input handle vector - it might be a
% non-homogenous array (e.g, some HG, some Simulink)
% The resulting arrays will be processed separately
% below.  Note that the Simulink handles are guarded
% so that we don't call Simulink when it's not necessary.
%
ishg = ishghandle(h);
hg = h(ishg);
if length(hg) ~= length(h),
  issl = isslhandle(h);
  sl = h(issl);
else
  sl = [];
end

if ~isempty(hg)
  if iscell(propValue)
    %Vectorize SET not used because propValue may vary per object
    values = propValue( logical(ishg) );
    if length(hg) ~= length(values)
      error('MATLAB:SETSET:InconsistentInputs',...
            'Inconsistent number of objects and property values.')
    end
    for i = 1:length(hg)
      set( hg(i), propName, values{i} )
    end
  else
    set( hg, propName, propValue )
  end
end

if ~isempty(sl)
  %set_param can not be vectorized because of the Lock issue.
  if iscell(propValue)
    values = propValue( logical(issl) );
  end
  for i = 1:length(sl)
    %If the block is a linked system, reassign the block so that
    %we are actually setting the block's reference system
    if ~strcmp(get_param(sl(i),'type'),'block_diagram')
      if strcmp(get_param(sl(i),'LinkStatus'),'resolved')
        sl(i) = get_param(get_param (sl(i),'ReferenceBlock'),'Handle');
      end
    end
    
    r = bdroot( sl(i) );
    
    LockSetting = get_param(r, 'Lock');
    DirtySetting = get_param(r,'Dirty');
    
    set_param( r , 'Lock', 'off');
    
    if iscell(propValue)
      set_param( sl(i), propName, values{i} );
    else
      set_param( sl(i), propName, propValue );
    end
    
    set_param( r, ...
               'Lock' , LockSetting,...
               'Dirty', DirtySetting);
  end
end
