%% Provides the OpenFcn callback for blocks that are 'links' to TLC 
%% or C files.


%   Copyright 2002-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/24 11:16:07 $

function sfundemo_openfcn
  
  edit(sfundemo_helper(matlabroot));
  