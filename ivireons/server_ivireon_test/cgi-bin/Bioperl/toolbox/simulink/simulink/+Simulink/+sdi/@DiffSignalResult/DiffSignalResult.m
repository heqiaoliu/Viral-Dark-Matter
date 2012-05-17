classdef DiffSignalResult < handle

    % Class DIFFSIGNALRESULT is a simple container class used to store the
    % detailed results of a signal comparison
    %
    % Properties
    % ----------
    %   'Match' - Do the two timeseries match.
    %
    %   'Diff'  - Difference between timeseries1 and timeseries2 as a
    %             timeseries object.
    %
    %   'Sync1' - timeseries1 after time synchronization applied.
    %
    %   'Sync2' - timeseries2 after time synchronization applied.
    %
    %   'Tol'   - Tolerance applied to value comparisons as a timeseries
    %             object.
    %
    % Copyright 2009-2010 The MathWorks, Inc.

    properties (Access = private)
        ID;
    end
    
    properties (Access = public)
        Match;
        Diff;
        Sync1;
        Sync2;
        Tol;
        LHSSignalID;
        RHSSignalID;
        LHSSignalObj;
        RHSSignalObj;
    end % Properties

    methods (Access = 'public')

        function this = DiffSignalResult()
            this.Match        = false;
            this.Diff         = [];
            this.Sync1        = [];
            this.Sync2        = [];
            this.Tol          = [];
            this.ID           = [];
            this.LHSSignalID  = [];
            this.RHSSignalID  = [];
            this.LHSSignalObj = [];
            this.RHSSignalObj = [];
        end

        function result = getID(this)
            if isempty(this.ID)
                % Cache class
                DSR = Simulink.sdi.DiffSignalResult;

                % Create ID
                this.ID = DSR.GetKeyStringforIDPair(this.LHSSignalID, ...
                                                    this.RHSSignalID);
            end
            result = this.ID;
        end

    end % methods

    methods (Static = true)

        function result = GetKeyStringForID(ID)
            if isempty(ID)
                result = 'empty';
            else
                result = int2str(ID);
            end
        end

        function result = GetKeyStringforIDPair(LHSSignalID, RHSSignalID)
            % The RHS can be empty while the LHS cannot
            if isempty(LHSSignalID)
                DAStudio.error('SDI:sdi:InvalidLHS');
            end

            % Cache class
            DSR = Simulink.sdi.DiffSignalResult;

            % Get individual key strings
            LHSKey = DSR.GetKeyStringForID(LHSSignalID);
            RHSKey = DSR.GetKeyStringForID(RHSSignalID);
            
            % Combine key strings
            result = [LHSKey, '_', RHSKey];
        end

    end % methods static

end % classdef