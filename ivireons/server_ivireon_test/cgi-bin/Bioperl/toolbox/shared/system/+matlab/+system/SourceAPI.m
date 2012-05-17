classdef SourceAPI < matlab.system.API
%matlab.system.SourceAPI Reserved for MathWorks internal use only

%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/01/25 22:48:30 $

  methods(Sealed)
    function status = isDone(this)
      %isDone  Returns a boolean indicating if System object has reached end-of-data
      %   isDone(OBJ) returns a Boolean indicating whether or not the
      %   source System object, OBJ, has reached the end of the source data
      %   (usually a file). For System objects that can loop, that is, read
      %   more than once, this method will return true every time the end
      %   is reached. For source System objects that do not have a concept
      %   of 'end of data', such as a live microphone feed, the isDone
      %   method will always return false. 
      status = mIsDone(this);
    end
  end
  
  % ------------
  % Constructor
  % ------------
  methods
    function this = SourceAPI(args)
      % call base constructor
      this = this@matlab.system.API(args);
    end
  end

  methods(Access=protected)
    function status = mIsDone(this)                              %#ok<MANU>
      status = false;
    end
    %%
  end
end

% [EOF]
