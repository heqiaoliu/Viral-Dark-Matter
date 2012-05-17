classdef SFunSourceAPI < matlab.system.SFunCoreAPI 
%matlab.system.SFunSourceAPI Reserved for MathWorks internal use only

% The base class for all S-function based source System objects

%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/01/25 22:48:28 $

  methods
    function this = SFunSourceAPI(libraryName, args)
      this = this@matlab.system.SFunCoreAPI(libraryName,args);
    end
    function status = isDone(this) %#ok<MANU>
      %isDone  Returns true if System object has reached end-of-data
      %   isDone(OBJ) returns true if the source System object, OBJ, has
      %   reached the end of the source data (usually a file). For System
      %   objects that can loop, that is, read more than once, this method
      %   will return true every time the end is reached. For source System
      %   objects that do not have a concept of 'end of data', such as a
      %   live microphone feed, the isDone method will always return false.
      status = false;
    end
  end

end

% [EOF]
