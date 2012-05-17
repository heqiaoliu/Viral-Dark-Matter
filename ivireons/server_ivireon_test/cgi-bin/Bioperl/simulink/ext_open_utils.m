function hfcns = ext_open_utils()
%
% Utility functions for External Mode Open Protocol user-implemented
% target interface file.
%

% Copyright 2005-2006 The MathWorks, Inc.
  
  hfcns.i_BlockLogEventCompleted       = @i_BlockLogEventCompleted;
  hfcns.i_SendBlockExecute             = @i_SendBlockExecute;
  hfcns.i_WriteSourceSignal            = @i_WriteSourceSignal;
  hfcns.i_WriteSourceDWork             = @i_WriteSourceDWork;
  hfcns.i_SendTerminate                = @i_SendTerminate;
  hfcns.i_ConvertSIToRWV               = @i_ConvertSIToRWV;
  hfcns.i_ConvertRWVToSI               = @i_ConvertRWVToSI;

%**************************************************************************
%                          PUBLIC FUNCTIONS
%**************************************************************************

function glbVars = i_BlockLogEventCompleted(glbVars, upInfoIdx, blkIdx)
%
% Marks a block as having fully uploaded all of the data associated with a
% logging event (a full duration worth of data).
%
if (~isempty(glbVars.glbUpInfoWired) && ...
        upInfoIdx == glbVars.glbUpInfoWired.index)
    glbVars.glbUpInfoWired.upBlks{blkIdx}.LogEventCompleted = true;
elseif (~isempty(glbVars.glbUpInfoFloating) && ...
        upInfoIdx == glbVars.glbUpInfoFloating.index)
    glbVars.glbUpInfoFloating.upBlks{blkIdx}.LogEventCompleted = true;
else
    DAStudio.error('Simulink:tools:extModeOpenUnknownUpInfoIdx');
end

% end i_BlockLogEventCompleted

function glbVars = i_SendBlockExecute(glbVars, upInfoIdx, blkIdx)
%
% Formats and sends a command to Simulink to execute a given block.
% The uploaded block consists of some number of TimeSeries objects, each
% representing a source signal for the uploaded block.  Once all of the
% data has been copied into each of the source signals, Simulink can execute
% the block.
%
if (~isempty(glbVars.glbUpInfoWired) && ...
        upInfoIdx == glbVars.glbUpInfoWired.index)
    blkName = glbVars.glbUpInfoWired.upBlks{blkIdx}.Name;
elseif (~isempty(glbVars.glbUpInfoFloating) && ...
        upInfoIdx == glbVars.glbUpInfoFloating.index)
    blkName = glbVars.glbUpInfoFloating.upBlks{blkIdx}.Name;
else
    DAStudio.error('Simulink:tools:extModeOpenUnknownUpInfoIdx');
end

mat    = cell(1,2);
mat{1} = get_param(blkName,'handle');
mat{2} = upInfoIdx;
set_param(glbVars.glbModel,'ExtModeOpenProtocolExecuteBlock',mat);

% end i_SendBlockExecute

function glbVars = i_WriteSourceSignal(glbVars, upInfoIdx, blkIdx, ...
                                       srcSigIdx, time, data)
%
% Writes the time and data vectors into the TimeSeries object for a
% particular source signal.  The 'src' input argument is the TimeSeries
% object used to store the data.  The time vector must be a column vector
% (e.g. Mx1) such as the following:
%
%   >> time
%   time
%
%   ans =
%
%            0
%       0.1000
%       0.2000
%       0.3000
%       0.4000
%       0.5000
%          .
%          .
%          .
%
% The data vector can have two different forms.  For one-dimensional data
% (i.e. a scalar or wide signal), the data entry must be an MxN matrix,
% where M is the number of timepoints (length of time vector) and N is
% the number of signal elements (1 for scalar, 2 or more for wide).
% For example, a two element wide signal would look like the following:
%
%   >> data
%   data
%
%   ans =
%
%       2.0000    2.1000
%       2.0000    2.1000
%       2.0000    2.1000
%       2.0000    2.1000
%       2.0000    2.1000
%          .         .
%          .         .
%          .         .
%
%
% For two or more dimensional data, the data entry must be an MxNx...xP matrix,
% where P, the last dimension, is equal to the number of timepoints (length of
% time vector) and all other dimensions are the dimensions of the signal itself.
% For example, a 3x3 matrix signal would look like the following:
%
%   >> data
%   data
%
%   data(:,:,1) =
%
%        1     1     1
%        1     1     1
%        1     1     1
%
%   data(:,:,2) =
%
%        1     1     1
%        1     1     1
%        1     1     1
%
%       .
%       .
%       .
%
% For the case of a 1-dimensional signal, the first dimension is the number
% of timepoints (equal to the length of the data vector).  For N-dimensional
% signals, where N is greater than 1, the last dimension is the number of
% timepoints.  When calling the init function of a timeseries object, the
% isTimeFirst field is true when the first dimension is the number of
% timepoints and false otherwise.
%
isTimeFirst = false;
if length(time) == 1
    dims = size(data);
    if ndims(data) == 1 || dims(1) == 1
        isTimeFirst = true;
    end
else
    if ndims(data) <= 2
        isTimeFirst = true;
    end
end

if (~isempty(glbVars.glbUpInfoWired) && ...
        upInfoIdx == glbVars.glbUpInfoWired.index)
    glbVars.glbUpInfoWired.upBlks{blkIdx}.SrcSignals{srcSigIdx}.Timeseries = ...
        glbVars.glbUpInfoWired.upBlks{blkIdx}.SrcSignals{srcSigIdx}.Timeseries.init(data,time,'isTimeFirst',isTimeFirst);
elseif (~isempty(glbVars.glbUpInfoFloating) && ...
        upInfoIdx == glbVars.glbUpInfoFloating.index)
    glbVars.glbUpInfoFloating.upBlks{blkIdx}.SrcSignals{srcSigIdx}.Timeseries = ...
        glbVars.glbUpInfoFloating.upBlks{blkIdx}.SrcSignals{srcSigIdx}.Timeseries.init(data,time,'isTimeFirst',isTimeFirst);
else
    DAStudio.error('Simulink:tools:extModeOpenUnknownUpInfoIdx');
end

% end i_WriteSourceSignal

function glbVars = i_WriteSourceDWork(glbVars, upInfoIdx, blkIdx, ...
                                      srcDWorkIdx, time, data)
%
% Similar to i_WriteSourceSignal(), except this is for writing source DWorks.
%
isTimeFirst = false;
if length(time) == 1
    dims = size(data);
    if ndims(data) == 1 || dims(1) == 1
        isTimeFirst = true;
    end
else
    if ndims(data) <= 2
        isTimeFirst = true;
    end
end

if (~isempty(glbVars.glbUpInfoWired) && ...
        upInfoIdx == glbVars.glbUpInfoWired.index)
    glbVars.glbUpInfoWired.upBlks{blkIdx}.SrcDWorks{srcDWorkIdx}.Timeseries = ...
        glbVars.glbUpInfoWired.upBlks{blkIdx}.SrcDWorks{srcDWorkIdx}.Timeseries.init(data,time,'isTimeFirst',isTimeFirst);
elseif (~isempty(glbVars.glbUpInfoFloating) && ...
        upInfoIdx == glbVars.glbUpInfoFloating.index)
    glbVars.glbUpInfoFloating.upBlks{blkIdx}.SrcDWorks{srcDWorkIdx}.Timeseries = ...
        glbVars.glbUpInfoFloating.upBlks{blkIdx}.SrcDWorks{srcDWorkIdx}.Timeseries.init(data,time,'isTimeFirst',isTimeFirst);
else
    DAStudio.error('Simulink:tools:extModeOpenUnknownUpInfoIdx');
end

% end i_WriteSourceDWork

function glbVars = i_SendTerminate(glbVars, upInfoIdx)
%
% Formats and sends a command to Simulink to terminate a logging session.
% If this is one-shot mode, we need to disable the trigger once the trigger
% event is over and then handle the EXT_TERMINATE_LOG_SESSION command.  This
% tells Simulink that we are done with the previous trigger and the trigger
% is now in the canceled state.
%
if (~isempty(glbVars.glbUpInfoWired) && ...
        upInfoIdx == glbVars.glbUpInfoWired.index)
    if i_AllBlocksLogEventCompleted(glbVars.glbUpInfoWired);
        glbVars = i_ResetBlocksLogEventCompleted(glbVars, glbVars.glbUpInfoWired.index);
        if glbVars.glbUpInfoWired.trigger.OneShot == 1
            glbVars.glbUpInfoWired.trigger_armed = 0;
            set_param(glbVars.glbModel,'ExtModeOpenProtocolTerminateLogSession',glbVars.glbUpInfoWired.index);
        else
            set_param(glbVars.glbModel,'ExtModeOpenProtocolTerminateLogEvent',glbVars.glbUpInfoWired.index);
        end
    end
elseif (~isempty(glbVars.glbUpInfoFloating) && ...
        upInfoIdx == glbVars.glbUpInfoFloating.index)
    if i_AllBlocksLogEventCompleted(glbVars.glbUpInfoFloating);
        glbVars = i_ResetBlocksLogEventCompleted(glbVars, glbVars.glbUpInfoFloating.index);
        if glbVars.glbUpInfoFloating.trigger.OneShot == 1
            glbVars.glbUpInfoFloating.trigger_armed = 0;
            set_param(glbVars.glbModel,'ExtModeOpenProtocolTerminateLogSession',glbVars.glbUpInfoFloating.index);
        else
            set_param(glbVars.glbModel,'ExtModeOpenProtocolTerminateLogEvent',glbVars.glbUpInfoFloating.index);
        end
    end
else
    DAStudio.error('Simulink:tools:extModeOpenUnknownUpInfoIdx');
end

% end i_SendTerminate

function allBlocksLogEventCompleted = i_AllBlocksLogEventCompleted(upInfo)
%
% Returns true if all uploading blocks have had their source signals upload
% data, false otherwise.  Once all blocks have uploaded all of their source
% signals, we can terminate the logging event.
%
allBlocksLogEventCompleted = true;
upBlks                     = upInfo.upBlks;
numUpBlks                  = length(upBlks);

for nUpBlk=1:numUpBlks
    if (upInfo.upBlks{nUpBlk}.LogEventCompleted == false)
        allBlocksLogEventCompleted = false;
        break;
    end
end

% end i_AllBlocksLogEventCompleted

function [dtObj isEnum] = i_GetDTypeObject(dTypeName, blockName)
%
% Gets the data type object from the data type name.  blockName can be
% empty (for example, a workspace parameter not associated with any
% particular block).
%
dtObj = [];
isEnum = false;

%
% Check for enum data type.
%
dtObj = Simulink.getMetaClassIfValidEnumDataType(dTypeName);
if ~isempty(dtObj)
    isEnum = true;
    return;
end

%
% Check for other data types.
%
try
    %
    % This will return a data type object for built-in and fixed-point
    % types.  Other types will throw an error.
    %
    dtObj = fixdt(dTypeName);
catch ME
    if ~isempty(blockName)
        %
        % If a block name is supplied, try to resolve the data type name.
        %
        try
            %
            % Should be able to get the data type object, else throw an
            % error for an unhandled data type.
            %
            dtObj = slResolve(dTypeName, blockName);
        catch ME
            DAStudio.error('Simulink:tools:extModeOpenUnhandledDataType', dTypeName);
        end
    else
        %
        % If no block name is supplied, try to find the data type in the
        % base workspace.  If it does not exist in the base workspace,
        % throw an error for an unhandled data type.
        %
        if evalin('base', ['exist(''' dTypeName ''')'])
            try
                %
                % The data type exists in the base workspace.  Try to eval
                % the type name.  If the type name is a type object in the
                % base workspace (e.g. some object derived from
                % Simulink.NumericType), this will return the data type
                % object.  If the data type name is something else (e.g.
                % a class name for enums) this will throw an error.
                %
                dtObj = evalin('base',dTypeName);
            catch ME
                try
                    %
                    % The data type exists in the base workspace and is not
                    % a data type object, so it must be some class (e.g. a
                    % class derived for enum types).  This will return the
                    % data type object for a class.  If this does not work,
                    % throw an error for an unhandled data type
                    %
                    dtObj = evalin('base',['?' dTypeName]);
                catch ME
                    DAStudio.error('Simulink:tools:extModeOpenUnhandledDataType', dTypeName);
                end
            end
        else
            DAStudio.error('Simulink:tools:extModeOpenUnhandledDataType', dTypeName);
        end
    end
end

function RWVs = i_ConvertSIToRWV(dTypeName, blockName, values)
%
% Converts values from Stored Integer (SI) form to Real-World Value (RWV)
% form based on the data type.  This function should be used when data
% acquired from Simulink is being downloaded to a target requiring RWV form.
% Fi objects may also be downloaded directly from Simulink.
%
% The input argument 'blockName' can be empty (for example, a
% workspace parameter not associated with any particular block).
%
% The input argument 'values' may be a fi object.  For example, if
% the data coming from Simulink is Multiword, it must be converted
% into a fi object (otherwise, there is no way to know the difference
% between a Multiword and an array of ints).  It is assumed the fi
% object was correctly created and contains both the RWV (fi.data)
% and the Stored Integer (fi.int).  It could also be some built-in
% data type or an enum.

[dtObj isEnum] = i_GetDTypeObject(dTypeName, blockName);

if isEnum
    %
    % The data type is an enum, meaning the input argument 'dTypeName'
    % is a class describing the enum.  Create the enum object from the
    % enum class with the given values, then cast it to an int32
    % (Enums always have equal RWV and SI forms, so this would be the
    % Stored Integer equivalent of the enum).
    %
    RWVs = int32(feval(dTypeName, values));
    
elseif isfi(values)
    %
    % Input argument 'values' is already a fi.  It is assumed the passed-in
    % fi object was correctly formed, so the RWV and SI values can be
    % retrieved directly from the fi object.
    %
    % Leave Multiword values as fi objects, otherwise return RWVs.
    % The Multiword fi objects will contain RWVs, but the fi object makes
    % it easy to pull out the RWV or SI values as needed.  For non-Multiword
    % fi objects, we return the RWV values directly although we could also
    % return the fi objects themselves if we wanted.
    %
    a=values(1);
    if length(a.simulinkarray) == 1
        RWVs = values.data;
    else
        RWVs = values;
    end
    
else
    if license('test','Fixed_Point_Toolbox')
        %
        % If a fixed-point license is available, use the fi object
        % to do the data conversion.
        %
        % Input argument 'values' must be in Stored Integer form.  To convert
        % to RWV form, create a fi object, set the integer data in the fi object
        % to 'values', then get the RWV values and return (the fi object does
        % the conversion for us).
        %
        % Leave Multiword values as fi objects, otherwise return RWVs.
        % The Multiword fi objects will contain RWVs, but the fi object makes
        % it easy to pull out the RWV or SI values as needed.  For non-Multiword
        % fi objects, we return the RWV values directly although we could also
        % return the fi objects themselves if we wanted.
        %
        fiVal = fi([], dtObj);
        fiVal.int = values;
        a=fiVal(1);
        if length(a.simulinkarray) == 1
            RWVs = fiVal.data;
        else
            RWVs = fiVal;
        end
    else
        try
            % Fixed-point license is not available, can't use fi.
            dtypeFunc = str2func(dTypeName);
            RWVs      = dtypeFunc(values);
        catch ME
            DAStudio.error('Simulink:tools:extModeOpenUnhandledDataType', dTypeName);
        end
    end
end

% end i_ConvertSIToRWV

function SIs = i_ConvertRWVToSI(dTypeName, blockName, values)
%
% Converts values from Real-World Value (RWV) form to Stored Integer (SI)
% form based on the data type.  This function should be used when data
% acquired from the target is in RWV form and must be converted to SI
% form before uploading to Simulink.  Fi objects may also be uploaded
% directly to Simulink.
%
% The input argument 'blockName' can be empty (for example, a
% workspace parameter not associated with any particular block).
%
% The input argument 'values' may be a fi object.  For example, if
% the data coming from the target is Multiword, it must be converted
% into a fi object (otherwise, there is no way to know the difference
% between a Multiword and an array of ints).  It is assumed the fi
% object was correctly created.  It could also be some built-in
% data type or an enum.
%

[dtObj isEnum] = i_GetDTypeObject(dTypeName, blockName);

if isEnum
    %
    % The data type is an enum, meaning the input argument 'dTypeName'
    % is a class describing the enum.  Create the enum object from the
    % enum class with the given values, then cast it to an int32
    % (Simulink stores enums as int32s, so this would be the Stored
    % Integer equivalent of the enum).
    %
    SIs = int32(feval(dTypeName, values));
    
elseif isfi(values)
    %
    % Input argument 'values' is already a fi.  It is assumed the passed-in
    % fi object was correctly formed, so the RWV and SI values can be
    % retrieved directly from the fi object.
    %
    % Leave Multiword values as fi objects, otherwise return stored ints.
    % The Multiword fi objects will contain RWVs, but the fi object makes
    % it easy to pull out the RWV or SI values as needed.  For non-Multiword
    % fi objects, we return the Stored Integer values directly although we
    % could also return the fi objects themselves if we wanted.
    %
    a=values(1);
    if length(a.simulinkarray) == 1
        SIs = values.int;
    else
        SIs = values;
    end
    
else
    if license('test','Fixed_Point_Toolbox')
        %
        % If a fixed-point license is available, use the fi object
        % to do the data conversion.
        %
        % Input argument 'values' must be in Real World Value form.  To convert
        % to SI form, create a fi object, set the data in the fi object to
        % 'values', then get the SI values and return (the fi object does the
        % conversion for us).
        %
        % Leave Multiword values as fi objects, otherwise return stored ints.
        % The Multiword fi objects will contain RWVs, but the fi object makes
        % it easy to pull out the RWV or SI values as needed.  For non-Multiword
        % fi objects, we return the Stored Integer values directly although we
        % could also return the fi objects themselves if we wanted.
        %
        fiVal = fi(values, dtObj);
        a=fiVal(1);
        if length(a.simulinkarray) == 1
            SIs = fiVal.int;
        else
            SIs = fiVal;
        end
    else
        try
            % Fixed-point license is not available, can't use fi.
            dtypeFunc = str2func(dTypeName);
            SIs       = dtypeFunc(values);
        catch ME
            DAStudio.error('Simulink:tools:extModeOpenUnhandledDataType', dTypeName);
        end
    end
end

% end i_ConvertRWVToSI

function glbVars = i_ResetBlocksLogEventCompleted(glbVars, upInfoIdx)
%
% Resets each uploading block's 'LogEventCompleted' flag to false.  This occurs
% when terminating a logging event in anticipation of the next logging event.
%
if (~isempty(glbVars.glbUpInfoWired) && ...
        upInfoIdx == glbVars.glbUpInfoWired.index)
    numUpBlks = length(glbVars.glbUpInfoWired.upBlks);
    for nUpBlk=1:numUpBlks
        glbVars.glbUpInfoWired.upBlks{nUpBlk}.LogEventCompleted = false;
    end
elseif (~isempty(glbVars.glbUpInfoFloating) && ...
        upInfoIdx == glbVars.glbUpInfoFloating.index)
    numUpBlks = length(glbVars.glbUpInfoFloating.upBlks);
    for nUpBlk=1:numUpBlks
        glbVars.glbUpInfoFloating.upBlks{nUpBlk}.LogEventCompleted = false;
    end
else
    DAStudio.error('Simulink:tools:extModeOpenUnknownUpInfoIdx');
end

% end i_ResetBlocksLogEventCompleted
