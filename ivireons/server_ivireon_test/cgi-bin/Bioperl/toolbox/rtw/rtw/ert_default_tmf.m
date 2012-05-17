function [tmf,envVal,otherOpts] = ert_default_tmf(varargin)
% ERT_DEFAULT_TMF Returns the "default" template makefile for use with ert.tlc
%
% See get_tmf_for_target in the toolbox/rtw/private directory for more 
% information.

% Copyright 1994-2010 The MathWorks, Inc.
% $Revision: 1.10.4.11 $

  if nargin > 0
      modelName = varargin{1};
  else
      modelName = bdroot;
  end
  osVal = LocalGetRTWOption(modelName,'TargetOS', 'BareBoardExample');
  
  sfVal = LocalGetRTWOption(modelName,'GenerateErtSFunction', 0);

  if strcmp(osVal,'BareBoardExample')
    [tmf,envVal,otherOpts] = get_tmf_for_target('ert');
  elseif strcmp(osVal,'VxWorksExample')
    if sfVal == 1
      txt = [ ...
	  'Note:', ...
	  sprintf('\n'), ...
	  'Not compiling the VxWorks target code since the', ...
	  sprintf('\n') ...
	  'option to create a SIL block is selected.', ...
	  sprintf('\n') ...
	  'Building SIL block instead.', ...
	    ];
      helpdlg(txt,'Real-Time Workshop Embedded Coder Help');
      [tmf,envVal,otherOpts] = get_tmf_for_target('ert');
    else
      tmf = 'ert_tornado.tmf';
      envVal = '';
      otherOpts = [];
    end
  else
    DAStudio.error('RTW:targetSpecific:tmfUnavailable');
  end
  

% Function: LocalGetRTWOption
%
% Abstract:
%   Find value of an RTW option by analyzing the rtwoptions string.
%
% Note:
%   Depending on the rtwoptions string is not guaranteed to be
%   backward capatible.  If you use this technique to access
%   RTW options, you'll need to test the functionality with each
%   release.
%
function value = LocalGetRTWOption(modelName,tlcVar, defaultVal)
  rtwoptions = get_param(modelName,'rtwoptions');
  
  str = ['-a',tlcVar,'='];
  idx = findstr(rtwoptions,str);
  
  if isempty(idx)
    value = defaultVal;
    
    if isnumeric(value)
      valueStr = num2str(value);
    else
      valueStr = value;
    end
        
    DAStudio.warning('RTW:targetSpecific:tlcVarUnavailable', tlcVar, valueStr);
    return;
  end
  
  strLen = length(str);
  startIdx = idx+strLen;
  nextChar = rtwoptions(startIdx);
  
  if nextChar ~= '"'
      value = str2double(nextChar);
  else
      startIdx = startIdx + 1;
      endIdx = findstr(rtwoptions(startIdx:end),'"');
      value = rtwoptions(startIdx:startIdx+endIdx(1)-2);
  end
  
%end ert_default_tmf.m
