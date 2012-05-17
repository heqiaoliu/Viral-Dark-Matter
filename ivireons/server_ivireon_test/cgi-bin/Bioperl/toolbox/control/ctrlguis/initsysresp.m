function initsysresp(r,RespType,Opts,RespStyle)
%INITSYSRESP  Generic initialization of system responses.
% 
%   INITSYSRESP(R,PlotType,PlotOpts,RespStyle)

%   Author(s): P. Gahinet, B. Eryilmaz
%   Revised  : Kamesh Subbarao
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.34.4.4 $ $Date: 2006/12/27 20:33:32 $

% RE: * invoked by LTI methods and LTI Viewer
%     * r is a @waveform instance

% Plot-type-specific settings
TimeResp = any(strcmp(RespType,{'step','impulse','initial','lsim'}));

% REVISIT: Insert logic here for stem or stair plots for discrete time
% responses (currently there are no stem plots)

% Built-in characteristics
if TimeResp && ~strcmp(RespType,'lsim')  
   % Show steady-state line
   r.addchar('FinalValue','resppack.TimeFinalValueData', 'resppack.TimeFinalValueView');
end

% User-defined plot style
if nargin>3
   r.setstyle(RespStyle)
end