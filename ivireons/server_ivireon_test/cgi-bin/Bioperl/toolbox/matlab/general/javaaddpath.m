function javaaddpath(varargin)
%JAVAADDPATH Add Java classes to MATLAB
%  JAVAADDPATH DIRJAR adds the specified directory or
%  jar file to the current dynamic Java path. 
%
%  When loading Java classes, MATLAB always searches the 
%  static Java path, defined in classpath.txt, before the 
%  dynamic Java path. Enter 'javaclasspath' to see the 
%  current static and dynamic Java path. Enter 'clear java' 
%  to reload Java classes defined on the dynamic Java path. 
%  Whenever the dynamic Java path is changed, 'clear java'
%  is automatically run.
%
%  JAVAADDPATH DIRJAR  ... adds directories or jar files
%  to the beginning of the current dynamic Java path.
%  Relative paths are converted to absolute paths.
%
%  JAVAADDPATH ... -END appends the specified directories.
%
%  Use the functional form of JAVAADDPATH, such as 
%  JAVAADDPATH({'dirjar','dirjar',...}), when the directory 
%  specification is stored in a string or cell array of
%  strings.
%
%  Example 1:
%  % Add a directory
%  javaaddpath D:/tools/javastuff 
%  % 'clear java' was used to reload modified Java classes
%
%  Example 2:
%  % Add an internet jar file 
%  javaaddpath http://www.example.com/my.jar
%  javaclasspath % View Java path
%
%  Example 3:
%  % Add the current working directory 
%  javaaddpath(pwd)
%
%  See also JAVACLASSPATH, JAVARMPATH, CLEAR, JAVA. 

% Copyright 2002-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2008/08/08 12:55:30 $

n = nargin;

error(nargchk(1,2,n));

append = false; % default, pre-append

if n>1
  last = varargin{2};
  
  % append 
  if strcmp(last,'-end')
    append = true;
  
  % pre-append  
  elseif strcmp(last,'-begin')
    append = false;
  end 
end

p = varargin{1};

% Append or prepend the new path   
if append
  javaclasspath( javaclasspath, p );
else
  javaclasspath( p, javaclasspath );
end



