function [sys, x0, str, ts] = vrextin(~, ~, ~, flag, Ts, vr_world, vr_field)
%VREXTIN Input signal from virtual reality scene. 
%   MATLAB code S-function.
%   This function sets the supplied VRML node field as "synchronized" and
%   reads the value of this field in each simulation step.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2010/02/08 23:02:31 $ $Author: batserve $

switch flag

% Initialization
  case 0

    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs     = 0;
    sizes.NumInputs      = 1;
    sizes.DirFeedthrough = 1;
    sizes.NumSampleTimes = 1;

    sys = simsizes(sizes);
    str = [];

    if ~isempty(Ts)
      ts = [Ts(1) 0];
    else
      ts = [-1 0];
    end

    x0=[];

    % create the vrworld object 
    wh = vrworld(vr_world);
    
    % open the world if it is not yet open
    if (~isopen(wh))
      open(wh);
    end
    
    % extract node name and field name from the supplied string
    idx = find(vr_field == '.');
    node_name = vr_field(1:idx(1)-1);
    field_name = vr_field(idx(1)+1:end);
    
    % get the node handle
    nh = vrnode(wh, node_name);
 
    % synchronise the field (update of the field value in the virtual scene is
    % reflected on the host)
    sync(nh, field_name, 'on');
 
    % read the synchronised field value
    field_value = nh.(field_name);
    
    % set the value of the adjacent Constant block 'value_holder' to the
    % new field value
    set_param([gcs '/value_holder'], 'Value', ['[' num2str(field_value) ']']);


% Update
  case 2

    % create the vrworld object 
    wh = vrworld(vr_world);
    
    % extract node name and field name from the supplied string
    idx = find(vr_field == '.');
    node_name = vr_field(1:idx(1)-1);
    field_name = vr_field(idx(1)+1:end);
    
    % get the node handle
    nh = vrnode(wh, node_name);
 
    % read the synchronised field value
    field_value = nh.(field_name);
    
    % set the value of the adjacent Constant block 'value_holder' to the
    % new field value
    set_param([gcs '/value_holder'], 'Value', ['[' num2str(field_value) ']']);

    sys=[];
    
    
% Unused flags
  case { 1, 3, 4, 5, 9 }
    sys = [];

% Other flags
  otherwise
    if ischar(flag),
      errmsg=sprintf('Unhandled flag: ''%s''', flag);
    else
      errmsg=sprintf('Unhandled flag: %d', flag);
    end

    error(errmsg);

end

% end vrextin
