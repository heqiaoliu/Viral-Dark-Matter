function platform_finder(gui_choice)
%PLATFORM_FINDER support utility for rtwdemo_rsim_param_tuning.mdl
%
%  Support file for rtwdemo_rsim_param_tuning.mdl demo.  This file is not 
%  intended to be a general purpose utility and may change without
%  notice in future versions.
%

%  Copyright 1994-2005 The MathWorks, Inc.
%  $Revision: 1.4.4.2 $  $Date: 2005/12/19 07:38:15 $


switch gui_choice
case ''
    % 
    % --- Skip GUI opening - model start callback only needs init code above
    %
case 'matlab_gui'
    %
    % --- Open the MATLAB GUI
    %
  chk = dir('rsim_rtp_struct.mat');   
  if isunix
    chk_exe = dir('rtwdemo_rsim_param_tuning');
  elseif ispc
    chk_exe = dir('rtwdemo_rsim_param_tuning.exe');
  end
  if ~isempty(chk) && ~isempty(chk_exe)
    disp('% ----- STEP 4: Opening the MATLAB RSIM GUI Demo ----- %')
    disp('>>rsim_gui(''rsim_rtp_struct.mat'')')
    rsim_gui('rsim_rtp_struct.mat')
  else
    msgbox('Please run the Demo sequentially by first executing steps 1 through 3.',...
	  'Demo Warning','help')
  end
end

%[EOF] platform_finder.m
