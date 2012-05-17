function B = saveobj(obj)
%SAVEOBJ Save filter for audiorecorder objects.
%
%    B = SAVEOBJ(OBJ) is called by SAVE when an audiorecorder object is
%    saved to a .MAT file. The return value B is subsequently used by
%    SAVE to populate the .MAT file.  
%  
%    SAVEOBJ will not save the recorded audio data.  In order to save
%    the recorded audio data, use GETAUDIODATA on the audiorecorder object.
%
%    See also AUDIORECORDER/LOADOBJ, AUDIORECORDER/GETAUDIODATA.

%    JCS
%    Copyright 2003-2005 The MathWorks, Inc.
%    $Revision $  $Date: 2007/07/26 19:29:19 $

% Get the properties of the audiorecorder object.
props = get(obj);

% Convert any property that may contain user specified data to 
% their respective SAVEOBJ structures so they are properly saved.
props.UserData = localSaveUserData(props.UserData);
props.StartFcn = localSaveUserData(props.StartFcn);
props.StopFcn = localSaveUserData(props.StopFcn);
props.TimerFcn = localSaveUserData(props.TimerFcn);

% Save these properties as the internal object which is a private member.
% We are purposefully deleting the internalObj here as a convenience for
% saving the properties.
obj.internalObj = props;

B = obj;

% **************************************
function out = localSaveUserData(input)
%Recursively saves an object's UserData.

if ( iscell(input) )
    % For cell arrays, recursively convert each cell element
    [m,n] = size(input);
    out = cell(m,n);
    for i=1:m
        for j=1:n
            out{i,j} = localSaveUserData( input{i,j} );
        end
    end
elseif ( isstruct(input) )
    % For structures, recursively convert each field value.
    fields = fieldnames(input);
    for f = 1:length(fields)
        fieldvalue = localSaveUserData( input.(fields{f}) );
        out.(fields{f}) = fieldvalue;
    end
else
    out = localInvokeSaveObj(input);
end

% **************************************
function out = localInvokeSaveObj(input)
% Helper function that converts non-cell and non-structs
% to their native SAVEOBJ structure.

try
    out = saveobj(input);
catch
    % If SAVEOBJ failed, nothing left to do except just return input.
    out = input;
end
