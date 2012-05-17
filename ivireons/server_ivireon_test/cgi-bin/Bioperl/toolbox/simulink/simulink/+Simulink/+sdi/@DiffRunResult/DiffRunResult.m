classdef DiffRunResult < handle

    % Class DIFFRUNRESULT stores the results of a comparison between two runs.
    % In other words, class DIFFRUNRESULT is an indexed container for objects
    % of type sdi.DiffResult.
    %
    % Properties
    % ----------
    % MatlabVersion - Version of MATLAB object instantiated in
    %                 (read-only)
    %
    % DateCreated   - Date object instantiated on in serial date number format.
    %                 (read-only)
    %
    % LHSDataRunSet - Instance of sdi.DataRunSet used as left operand of
    %                 comparison.
    %                 (Required by constructor)
    %
    % RHSDataRunSet - Instance of sdi.DataRunSet used as right operand of
    %                 comparison.
    %                 (Required by constructor)
    %
    % AlignmentMap  - Set of pairings of sdi.Data with LHS and RHS fields
    %                 (Required by constructor)
    %
    % ResultMap     - Instance of sdi.DataMap.  The key is the pairings in the
    %                 AlignmentMap.  The data stored for each key is an instance
    %                 of sdi.DiffResult.
    %
    %
    % Methods
    % -------
    % AddResult(LHSData, RHSData, diffResult)
    %
    % Adds a new difference result to the ResultMap table.  LHSData and RHSData
    % are both instances of sdi.Data.  diffResult is an instance of
    % sdi.DiffResult.
    %
    %
    % diffResult = LookupResult(LHSData, RHSData)
    %
    % Query ResultMap for a specific difference result.  If no such result is
    % present then the empty matrix is returned.  LHSData and RHSData are
    % both instances of sdi.Data.  diffResult is an instance of sdi.DiffResult.
    %
    % Copyright 2009-2010 The MathWorks, Inc.

    properties(Access = 'private')
        % Input data
        LHSDataRunID;   % ID of the LHS data run
        RHSDataRunID;   % ID of the RHS data run

        % Meta data
        MatlabVersion;  % Version of MATLAB that the object was generated.
        DateCreated;    % Date it was created.

        % Output data - comparison results
        DiffResultMap;  % Map to store the comparison results.
    end

    properties(Access = 'public')
        Name; % Do we need this?
    end

    methods

        % Constructor
        function this = DiffRunResult()
            % Inputs
            this.LHSDataRunID = [];
            this.RHSDataRunID = [];

            % Meta
            this.MatlabVersion = version;
            this.DateCreated   = now;

            % Outputs
            this.DiffResultMap = Simulink.sdi.Map(char(' '), ?handle);
        end

        function result = getLHSDataRunID(this)
            result = this.LHSDataRunID;
        end

        function result = getRHSDataRunID(this)
            result = this.RHSDataRunID;
        end

        function setLHSDataRunID(this, ID)
            this.LHSDataRunID = ID;
            end

        function setRHSDataRunID(this, ID)
            this.RHSDataRunID = ID;
        end

        function clear(this)
            % Inputs
            this.LHSDataRunID = [];
            this.RHSDataRunID = [];

            % Meta
            this.MatlabVersion = [];
            this.DateCreated   = [];

            % Outputs
            this.DiffResultMap.Clear;
        end

        function result = lookupResult(this, LHSSignalID, RHSSignalID)
            % Cache handle to DiffSignalResult class
            DSR = Simulink.sdi.DiffSignalResult;

            % Form lookup key for this LHS/RHS pair
            Key = DSR.GetKeyStringforIDPair(LHSSignalID, RHSSignalID);

            % Check if such a result exists
            result = this.DiffResultMap.getDataByKey(Key);
        end

        function addResult(this, DiffSignalResult)
            % Validate input types
            if ~isa(DiffSignalResult, 'Simulink.sdi.DiffSignalResult')
                DAStudio.error('SDI:sdi:ValidateMapInputs', ...
                               'Simulink.sdi.DiffSignalResult');
            end

            % Insert difference result into map
            this.DiffResultMap.insert(DiffSignalResult.getID(), DiffSignalResult);
        end

        function result = getResultByKey(this, key)
            if(this.DiffResultMap.isKey(key))
            result = this.DiffResultMap.getDataByKey(key);
            else
                result = [];
            end
        end

        function result = getResultByIndex(this, index)
            result = this.DiffResultMap.getDataByIndex(index);
        end

        function result = getCount(this)
            result = this.DiffResultMap.getCount();
        end

    end % public methods

    methods (Hidden = true)
        % Use for testing
        function diffResultMap = getDiffResultMap(this)
           diffResultMap = this.DiffResultMap;
        end
    end

end % classdef