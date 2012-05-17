function out = fieldnames(obj, flag)
%FIELDNAMES Get audiorecorder object property names.
%
%    NAMES = FIELDNAMES(OBJ) returns a cell array of strings containing 
%    the names of the properties associated with the audiorecorder object, OBJ.
%    
%    NAMES = FIELDNAMES(OBJ, '-full') returns a cell array of strings 
%    containing the name, type, attributes, and inheritance of each 
%    field associated with the audiorecorder object, OBJ.

%    JCS
%    Copyright 2003-2005 The MathWorks, Inc.
%    $Revision $  $Date: 2007/07/26 19:29:18 $

% Error checking
if ~isa(obj, 'audiorecorder')
   error('MATLAB:audiorecorder:noAudiorecorderObj', ...
         audiorecordererror('MATLAB:audiorecorder:noAudiorecorderObj'));
end

error(nargchk(1, 2, nargin, 'struct'));

% If -full is specified
if (nargin == 2)
   % This will error with 'Unknown command option' if -full not passed
   out = fieldnames(obj.internalObj, flag);

   % Replace class name with M-object class name so that everything says
   % 'Inherited from audiorecorder'
   if ispc
      out = strrep(out,'winaudiorecorder', 'audiorecorder');
   else
      out = strrep(out,'com.mathworks.toolbox.audio.JavaAudioRecorder', ...
                   'audiorecorder');
   end
else
   out = fieldnames(obj.internalObj);
end

