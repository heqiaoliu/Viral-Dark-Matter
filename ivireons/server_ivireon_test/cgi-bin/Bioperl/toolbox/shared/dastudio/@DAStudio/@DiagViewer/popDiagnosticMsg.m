function popDiagnosticMsg(h,msg)
%  POPDIAGNOSTICMSG
%  This pops the matching diagnostic message from the
%  viewer window
%  Copyright 1990-2008 The MathWorks, Inc.
  
%  $Revision: 1.1.8.1 $ 

msg = h.convertNagToUDDObject(msg);
msg = convertMsgToStruct(msg);

for i = length(h.messages):-1:1
    if isequal(msg,convertMsgToStruct(h.messages(i)))
        % pop this message

        h.messages(i) = [];

        if ~isempty(h.Explorer)
            
            if isempty(h.messages)
                h.flushMsgs;
            else
                h.updateWindow;
            end
        end  

        return;
    end
end

function msg = convertMsgToStruct(msg)
    msg = struct(msg);
    msg.Contents = struct(msg.Contents);
