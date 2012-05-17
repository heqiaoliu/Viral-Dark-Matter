function sf_keyboard(varargin)
%SF_KEYBOARD  used for debugging. 

%   Vijaya Raghavan
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.7.2.2 $  $Date: 2008/12/01 08:07:21 $

if(nargin>0)
   mesg = varargin{1};
else
   mesg = '';
end
if(nargin>1)
   data = varargin{2};
else
   data = [];
end
disp('Keyboard called from SF dll:');
if(~isempty(mesg))
   disp(mesg);
end
keyboard;