function gtable = cmgamdef(c)
%CMGAMDEF Default gamma correction table.
%   CMGAMDEF('computer') returns the default gamma correction 
%   table for the computer in the string computer.  See the
%   function COMPUTER for possibilities.  CMGAMDEF is called
%   by CMGAMMA.
%
%   CMGAMDEF returns the default gamma correction table for
%   the computer currently running MATLAB.
%
%   See also CMGAMMA, COMPUTER.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.13.4.3 $  $Date: 2004/08/10 01:38:52 $

if nargin == 0 
    c = computer; 
end
if ~ischar(c) 
    eid = 'Images:cmgamdef:expectedString';
    error(eid, '%s', 'Input argument must be a string.'); 
end

% Note: the gtable can have any number of rows.  See TABLE1 and
% CMGAMMA for details.
gtable = (0:.05:1)'*ones(1,4);
