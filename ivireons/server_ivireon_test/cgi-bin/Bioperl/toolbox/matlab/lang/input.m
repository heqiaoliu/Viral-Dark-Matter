%INPUT  Prompt for user input. 
%   R = INPUT('How many apples') gives the user the prompt in the
%   text string and then waits for input from the keyboard.
%   The input can be any MATLAB expression, which is evaluated,
%   using the variables in the current workspace, and the result
%   returned in R.  If the user presses the return key without 
%   entering anything, INPUT returns an empty matrix.
%
%   R = INPUT('What is your name','s') gives the prompt in the text
%   string and waits for character string input.  The typed input
%   is not evaluated; the characters are simply returned as a 
%   MATLAB string.
%
%   The text string for the prompt may contain one or more '\n'.
%   The '\n' means skip to the beginning of the next line. This
%   allows the prompt string to span several lines. To output
%   just a '\' use '\\'.
%
%   See also KEYBOARD.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 5.9.4.3 $  $Date: 2005/06/27 22:49:04 $
%   Built-in function.
