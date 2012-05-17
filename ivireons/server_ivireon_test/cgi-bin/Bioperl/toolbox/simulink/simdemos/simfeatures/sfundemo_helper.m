%% Provides the paths for functions relating to blocks that 
%% are 'links' to TLC or C files.


%   Copyright 2002-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/05/14 17:51:03 $

function x = sfundemo_helper(root)
    
  shortFileName = get_param(gcb, 'filename');
  
  [path,name,ext] = fileparts(shortFileName);
  
  switch ext
   case '.tlc'
    midpath = fullfile('toolbox','simulink','simdemos','simfeatures','tlc_c','');
   case {'.c', '.cpp','.F'}
    midpath = fullfile('toolbox','simulink','simdemos','simfeatures','src','');
   case '.m'
    midpath = fullfile('toolbox','simulink','simdemos','simfeatures','');
   case '.h'
    midpath = fullfile('toolbox','simulink','simdemos','simfeatures','include','');
   case '.adb'
    midpath = fullfile('toolbox','simulink','simdemos','simfeatures','src_ada',name,'');
   otherwise
    midpath = '???';
  end
  
  x = fullfile(root, midpath, shortFileName);
  