%MSLException - constructs an object, which is a subclass of the MATLAB 
%   MException class.
%   MSLE = MSLException(HANDLES, MSGID, ERRMSG) constructs a Simulink exception 
%   object, MSLE, of class MSLException and assigns to that object a handle 
%   (HANDLES), an identifier (MSGID), and an error message (ERRMSG). This  
%   object provides you with properties and methods to use in your program 
%   code for generating errors, for identifying the objects associated with  
%   an error, and for responding to errors.
%   
%   HANDLES is a cell array of handles to objects, such as Simulink blocks,
%   that are associated with the exception.
%
%   MSGID is a unique message identifier string to better identify the 
%   source of the error. (See MESSAGE IDENTIFIERS in the help for the ERROR 
%   function.)
%
%   ERRMSG is a character string that informs you about the cause of
%   the error and can also suggest how to correct the faulty condition. 
%
%   EXAMPLE:
%      MSLE = MSLException([1, 2], 'my:msg:id', 'my message');
%
%   As with MException, you can use a TRY-CATCH block to capture the
%   exception:
%
%      errHndls = []
%      try
%         Perform one or more operations
%      catch E
%         if isa(E, 'MSLException');
%            errHndls = e.handles{1};
%         else %not a Simulink error
%            rethrow(E)
%         end
%      end
%
%
%   See also MEXCEPTION, HANDLE, ERROR, TRY, CATCH, DBSTACK 
%
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.2 $
%   Built-in function.
