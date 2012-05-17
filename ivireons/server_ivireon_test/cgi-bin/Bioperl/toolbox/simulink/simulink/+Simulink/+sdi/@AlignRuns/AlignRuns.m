classdef AlignRuns < handle

    % Class Align implements the alignment of signals between runs.  The left-hand
    % side is considered the truth, and the right-hand side must align to it.
    %
    % Copyright 2009-2010 The MathWorks, Inc.

    properties (Access = public)
        ErrorLog;
    end

    properties (Access = private)
        % Two data runs to align
        EnumMap;
        AlignMap;
        SDIEngine;
        LHSDataRunID;
        RHSDataRunID;
        reverseMap;
        
        MapMethodUnset;
        MapMethodNone;
        MapMethodPath;
        MapMethodSID;
        MapMethodDataSrc;        
        mapMethodSignal;
    end

    methods

        function this = AlignRuns(sdiEngine)
            % Cache params
            if ~isa(sdiEngine, 'Simulink.sdi.SDIEngine')
                DAStudio.error('SDI:sdi:InvalidSDIEngine')
            end
            this.SDIEngine    = sdiEngine;
            this.EnumMap      = Simulink.sdi.Map(uint32(0), char(' '));
            this.AlignMap     = Simulink.sdi.Map(uint32(0), ?handle);
            this.reverseMap   = Simulink.sdi.Map(uint32(0), uint32(0));
            this.LHSDataRunID = [];
            this.RHSDataRunID = [];            
            stringDict = Simulink.sdi.StringDict;            
            
            this.MapMethodUnset   = 'Unset';
            this.MapMethodNone    = stringDict.mgNone;
            this.MapMethodPath    = stringDict.mgPath;
            this.MapMethodSID     = 'SID';
            this.MapMethodDataSrc = stringDict.IGDataSourceColName;
            this.mapMethodSignal  = stringDict.mgSigLabel;
        end

        function clear(this)
            this.LHSDataRunID = [];
            this.RHSDataRunID = [];            
            this.EnumMap.Clear();
            this.AlignMap.Clear();
        end

        function count = getCount(this)
            count = this.AlignMap.getCount();
        end

        function id = getLHSDataRunID(this)
            id = this.LHSDataRunID;
        end

        function id = getRHSDataRunID(this)
            id = this.RHSDataRunID;
        end

        function setLHSDataRunID(this, DataRunID)
            this.LHSDataRunID = this.getValidateRunID(DataRunID);
        end
        
        function setRHSDataRunID(this, DataRunID)
            this.RHSDataRunID = this.getValidateRunID(DataRunID);
        end

        function type = getLHSTypeByID(this, id)
            type = this.EnumMap.getDataByKey(id);
        end

        function value = getLHSValueByIndex(this, index)
            value = this.AlignMap.getKeyByIndex(index);
        end

        function type = getLHSTypeByIndex(this, index)
            type = this.EnumMap.getDataByIndex(index);
        end

        function type = getRHSValueByID(this, id)
            type = this.AlignMap.getDataByKey(id);
        end

        function value = getRHSValueByIndex(this, index)
            value = this.AlignMap.getDataByIndex(index);
        end

        function setLHSType(this, SignalID, value)
            switch value
                case Simulink.sdi.AlignType.BlockPath
                    this.EnumMap.insert(SignalID, this.MapMethodPath);
                case Simulink.sdi.AlignType.SID
                    this.EnumMap.insert(SignalID, this.MapMethodSID);
                case Simulink.sdi.AlignType.DataSource
                    this.EnumMap.insert(SignalID, this.MapMethodDataSrc);
                case Simulink.sdi.AlignType.Unset
                    this.EnumMap.insert(SignalID, this.MapMethodUnset);
                case Simulink.sdi.AlignType.SignalName
                    this.EnumMap.insert(SignalID, this.mapMethodSignal);
                otherwise
                    DAStudio.error('SDI:sdi:ValidateType',...
                                   'Simulink.sdi.AlignType');                   
            end            
        end
        
        function setRHSValue(this, LHSSignalID, RHSSignalID)
            this.AlignMap.insert(LHSSignalID, RHSSignalID);
            if ~isempty(RHSSignalID)
                this.reverseMap.insert(RHSSignalID, LHSSignalID);
            end
        end

        function result = isTypeUnset(this, id)
            type   = this.getLHSTypeByID(id);
            result = strcmp(type, this.MapMethodUnset);
        end

        function result = isRHSUsed(this, id)
            try
                this.reverseMap.getDataByKey(id);
                result = true;
            catch %#ok
                result = false;
            end
        end

        function applyUnset(this)
            tsr = Simulink.sdi.SignalRepository;
            
            for i = 1 : tsr.getSignalCount(this.LHSDataRunID)                
                LHSID = tsr.getID(this.LHSDataRunID, i);
                this.setLHSType(LHSID, Simulink.sdi.AlignType.Unset);
                this.setRHSValue(LHSID, []);
            end
        end
        
        function applyPath(this)
            % Iterate over the left signals list and find corresponding
            % right signal based on the path.
            tsr = Simulink.sdi.SignalRepository;
            for i = 1 :  tsr.getSignalCount(this.LHSDataRunID) 
                % Cache ith LHS signal object and ID                
                LHSSignalObj = tsr.getSignal(int32(this.LHSDataRunID), int32(i));
                LHSSignalID  = LHSSignalObj.DataID;
                
                % Only proceed if signal unaligned
                if this.isTypeUnset(LHSSignalID)
                    for j = 1 :  tsr.getSignalCount(this.RHSDataRunID)                        
                        RHSSignalObj = tsr.getSignal(int32(this.RHSDataRunID), int32(j));
                        RHSSignalID  = RHSSignalObj.DataID;
                        
                        % If signals match by path
                        if this.SignalsEqualByBlockPath(LHSSignalObj, RHSSignalObj)
                            this.setLHSType(LHSSignalID,...
                                            Simulink.sdi.AlignType.BlockPath);
                            this.setRHSValue(LHSSignalID, RHSSignalID);
                        end % if match
                    end % for j
                end % if signal unaligned
            end % for
        end % applyPath

        function result = SignalsEqualByBlockPath(this,         ...
                                                  LHSSignalObj, ...
                                                  RHSSignalObj)
            % Check if blocks match
            result = strcmp(LHSSignalObj.BlockSource, RHSSignalObj.BlockSource);

            % If blocks match then check ports - may be empty
            if result
                PortsEmpty = isempty(LHSSignalObj.PortIndex) && isempty(RHSSignalObj.PortIndex);
                result     = PortsEmpty || (LHSSignalObj.PortIndex == RHSSignalObj.PortIndex);
            end

            % If blocks and ports match then check channel dimensions
            if result
                result = all(size(LHSSignalObj.Channel) == size(RHSSignalObj.Channel));
            end

            % If blocks, ports, and channel dimensions match, check channels
            if result
                result = all(LHSSignalObj.Channel == RHSSignalObj.Channel);
            end
        end

        function applySID(this)
            % Iterate over the left signals list and find corresponding
            % right signal based on SID.
            tsr = Simulink.sdi.SignalRepository;
            for i = 1 :  tsr.getSignalCount(this.LHSDataRunID)
                LHSSignalObj = tsr.getSignal(int32(this.LHSDataRunID), int32(i));
                
                % Get the ID and SID of the ith LHS signal
                LHSSignalID  = LHSSignalObj.DataID;               
                LHSSignalSID = LHSSignalObj.SID;

                % Only proceed if signal unaligned and has an SID
                if this.isTypeUnset(LHSSignalID) && ~isempty(LHSSignalSID)

                    for j = 1 : tsr.getSignalCount(this.RHSDataRunID) 
                        % Cache jth RHS signal object
                        RHSSignalObj = tsr.getSignal(int32(this.RHSDataRunID), int32(j)); 
                        
                        % Get the ID and SID of the jth RHS signal
                        RHSSignalID  = RHSSignalObj.DataID;
                        RHSSignalSID = RHSSignalObj.SID;

                        % If the SIDs match, set alignment
                        if strcmp(LHSSignalSID, RHSSignalSID)
                            this.setLHSType(LHSSignalID,...
                                            Simulink.sdi.AlignType.SID);
                            this.setRHSValue(LHSSignalID, RHSSignalID);
                        end
                    end % for j
                end % % if signal unaligned
            end % for i
        end % applySID

        function applySignal(this)
            % Iterate over the left signals list and find corresponding
            % right signal based on SID.
            tsr = Simulink.sdi.SignalRepository;
            for i = 1 :  tsr.getSignalCount(this.LHSDataRunID)
                LHSSignalObj = tsr.getSignal(int32(this.LHSDataRunID), int32(i));
                
                % Get the ID and SID of the ith LHS signal
                LHSSignalID  = LHSSignalObj.DataID;               
                LHSSignalName = LHSSignalObj.SignalLabel;

                % Only proceed if signal unaligned and has an SID
                if this.isTypeUnset(LHSSignalID) && ~isempty(LHSSignalName)

                    for j = 1 : tsr.getSignalCount(this.RHSDataRunID) 
                        % Cache jth RHS signal object
                        RHSSignalObj = tsr.getSignal(int32(this.RHSDataRunID), int32(j)); 
                        
                        % Get the ID and SID of the jth RHS signal
                        RHSSignalID  = RHSSignalObj.DataID;
                        RHSSignalName = RHSSignalObj.SignalLabel;

                        % If the SIDs match, set alignment
                        if strcmp(LHSSignalName, RHSSignalName) &&...
                                  ~this.isRHSUsed(RHSSignalID)
                            this.setLHSType(LHSSignalID,...
                                            Simulink.sdi.AlignType.SignalName);
                            this.setRHSValue(LHSSignalID, RHSSignalID);
                        end
                    end % for j
                end % % if signal unaligned
            end % for i
        end % applySID

        function applyDataSrc(this)
            tsr = Simulink.sdi.SignalRepository;
            % First build a Map of the right side for quicker lookup
            RHMap = Simulink.sdi.Map(char(' '), uint32(0));
            for i = 1 : tsr.getSignalCount(this.RHSDataRunID)  
                RHSSignalObj = tsr.getSignal(int32(this.RHSDataRunID), int32(i));
                rightDataSrc = RHSSignalObj.DataSource;
                [ ~, remain] = strtok( rightDataSrc, '.');
                RHSSignalID = RHSSignalObj.DataID;
                RHMap.insert(remain(2:end), RHSSignalID);
            end
            
            % Iterate over the left signals list and find corresponding right
            % signal based on the DataSrc.
            for i = 1 : tsr.getSignalCount(this.LHSDataRunID) 

                % Look for signals with None enum.
                LHSSignalObj = tsr.getSignal(int32(this.LHSDataRunID), int32(i));
                LHSSignalID = LHSSignalObj.DataID;
                if this.isTypeUnset(LHSSignalID)
                    leftDataSrc = LHSSignalObj.DataSource;
                    [ ~, remain] = strtok( leftDataSrc, '.');              
                   
                   if(RHMap.isKey(remain(2:end)))
                       RHSSignalID = RHMap.getDataByKey(remain(2:end));
                        % Then both runs have the same DataSrc
                        this.setLHSType(LHSSignalID,...
                                        Simulink.sdi.AlignType.DataSource);
                        this.setRHSValue(LHSSignalID, RHSSignalID);
                    end
                end
            end % for
        end % function applyDataSrc

        function status = validateMap(this)
            status = true;
            % Prealocate size
            errorLogL = cell(1,2);
            errorLogR = cell(1,2);
            this.ErrorLog = {errorLogL, errorLogR};
        end

        function applyAll(this)
            this.applyUnset();
            this.applyDataSrc();
            this.applyPath();
            this.applySID();
            this.applySignal();
        end

        function RHSSignalID = getAlignedID(this, LHSSignalID)
            RHSSignalID = this.AlignMap.getDataByKey(LHSSignalID);
        end

    end % methods public

    methods (Access = 'private')

        function dataRun = getValidateRunID(this, runID)
            dataRun = [];%#ok
            % Validate param represent valid id. 
            tsr = Simulink.sdi.SignalRepository;            
            if ~tsr.isValidRunID(runID)
                DAStudio.error('SDI:sdi:InvalidRunID');
            end
            dataRun = runID;            
        end
        
    end % methods private

end % classDef
