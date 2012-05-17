%TARGETSUTILS_BINS bin data structure
%   TARGETSUTILS_BINS bin data structure

%   Copyright 1990-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/15 15:04:41 $

classdef TargetsUtils_Bins < handle

  properties(SetAccess = 'protected', GetAccess = 'protected')
    bins = {};
    binIds = {};
    isChar = false;
  end

  methods

    % This method adds an element to a bin with binId. If a bin with binId does
    % not exist then it will be created
    function addElement(this, binId, element)
      % Check if this bin exists yet
      [member location] = this.isaMember(binId);
      if ~member
        % Bin binId does not exist
        % Add this binId
        this.binIds(end + 1) = { binId };
        % Create an empty data location
        this.bins{end + 1} = {};
        % Add the data
        this.bins{end} = [this.bins{end} element];
      else
        % Bin binId already exists
        % Already a member
        this.bins{location} = [this.bins{location} element];
      end
    end % function addElement

    % This method gets the data in bin binId
    function binData = getBin(this, binId)
      [member location] = this.isaMember(binId);
      if member
        binData = this.bins{location};
      else
        binData = {};
      end
    end % function getBin

    % This method emptys the bin binId
    function clearBin(this, binId)
      [member location] = this.isaMember(binId);
      if member
        this.bins{location} = {};
      end
    end % function clearBin

  end % methods

  methods(Access = 'private')

    function [member location] = isaMember(this, binId)
      member = false;
      location = 0;
      lenBinIds = length(this.binIds);
      locationIdxs = 1:lenBinIds;
      if this.isChar
        % binId is a char so we use strcmp
        for i=1:lenBinIds
          result = strcmp(binId, this.binIds{i});
          location(i) = double(result);
          member = xor(result, member);
        end
      else
        % binId is not a char so we use ==
        for i=1:lenBinIds
          result = binId == this.binIds{i};
          location(i) = double(result);
          member = xor(result, member);
        end
      end
      if member
        location = locationIdxs(location == 1);
      end
    end % function isaMember

  end % methods(Access = 'private')

end % classdef
