function blkpath = removeNewLine(this,blkpath)
% REMOVENEWLINE Remove new lines from Simulink block names
 
% Author(s): John W. Glass 08-Oct-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:58:39 $

blkpath = regexprep(blkpath,'\n',' ');
