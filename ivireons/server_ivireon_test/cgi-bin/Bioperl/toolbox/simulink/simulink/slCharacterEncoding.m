function varargout = slCharacterEncoding(varargin)
% SLCHARACTERENCODING: Change the MATLAB character encoding setting.
%    If you have a model containing non-ASCII characters, you need to 
%    change the MATLAB character set encoding to be compatible with 
%    these characters before loading the model. If you see garbled 
%    characters in text objects (such as annotations) in a Simulink, the 
%    likely cause is an incorrect character encoding setting in MATLAB. 
%    Currently, MATLAB supports: 'US-ASCII', 'Shift_JIS', 'ISO-8859-1', 
%    'IBM-5348_P100-1997', 'cp1252'.
%
%    You need to close all open models and libraries before changing the
%    MATLAB character set encoding except when changing from 'US-ASCII' to
%    another encoding.
% 
%    Common character encoding settings by platform:
%      Unix, Linux, Mac             : 'US-ASCII', 'Shift_JIS'
%      Hp-UX                        : 'ibm-1051_P100-1995'  
%      Windows (USA, Western Europe): 'IBM-5348_P100-1997', 'cp1252'
%      Windows (Japan)              : 'Shift_JIS'
%      Windows (Other)              : 'ISO-8859-1'
%    Any setting can be used on any platform. For maximum portability across
%    platforms and locales, it is recommended that you set the default character
%    encoding to 'US-ASCII'
%
%    Usage:
% 
%    slCharacterEncoding()                  % display the current MATLAB 
%                                           % character set encoding
%
%    enc = slCharacterEncoding()            % return the current MATLAB 
%                                           % character set encoding
%
%    slCharacterEncoding('Shift_JIS')       % change the MATLAB character set 
%                                           % encoding to Shift_JIS
%  
%    prev = slCharacterEncoding('US-ASCII') % change the MATLAB character set 
%                                           % encoding to Shift_JIS, and 
%                                           % return previous encoding in 
%                                           % 'prev'
%
  
% Copyright 2004 The MathWorks, Inc.
% $Revision: 1.1.4.6 $

  % Get the old encoding before setting up the new one
  prevEncoding = get_param(0, 'CharacterEncoding');

  if nargin > 0
    newEncoding = varargin{1};

    if ~isempty(newEncoding)
      set_param(0, 'CharacterEncoding', newEncoding);
    end
  end
  
  if nargout == 1 || nargin == 0
    varargout = {prevEncoding};
  else
    varargout = {};
  end
% eof