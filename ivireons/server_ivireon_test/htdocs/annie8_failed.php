<html>
<head>
<title>ANNIE - Artificial Neural Network Interactive Experience</title>
</head>

<body>
<br><b><big>ANNIE - the Artificial Neural Network Interactive Experience</b></big><br><br>
Suppose you have some proteins<br>
<FONT COLOR=0000CD>And suppose you'd like to know:</FONT><br><br>
Are these phage major capsid proteins? Could they be tail proteins?<br><br>
<FONT COLOR=0000CD>Well, thanks to the <i>magic</i> of Artificial Neural Networks, we can <b>take a guess!</b></FONT><br><br>
Just input the file-paths for your fasta file and Matlab into the following text boxes.



<FORM action="/cgi-bin/Bioperl/pctpi_get4_failed.cgi" method="GET">
Fasta File Path: <input type="text" name="fastafile">  <br>
Matlab File Path: <input type="text" name="matlabpath">  <br>

<!--New File Name: <input type="text" name="newfilename"> <br>-->
<input type="submit" value="Submit"> <br><br><br><br>


<big>Instructions:</big><br><br>
Step 1: MAMP<br>
MAMP is a set of software, which allows you to run web-pages from your machine. This interface utilizes web-pages and programs to use the ANN software.<br>
First, download, install, and run MAMP on your machine. The software can be found at this location <a href="http://www.mamp.info/en/index.html">Here!</a><br>
Make sure to click "start servers", and wait for the light next to "Apache Server" to turn green. (the machine will see itself as a server).<br>
<img src="/pics/mamp_program.png" alt="nerding" width="350" height="300" /></img><br>
Next, find the MAMP directory on your machine; it may be in the "Applications" directory, and should look like this:<br>
<img src="/pics/mamp_dir.png" alt="nerding" width="450" height="300" /></img><br>
Replace the "htdocs" and "cgi-bin" directories with those found in the ANNIE packet (drag those folders from the packet to the MAMP folder, and click "Replace".<br><br>
Finally, open a web-browser, and try to go to: http://localhost/<br>
It will hopefully look like this:<br>
<img src="/pics/localhost.png" alt="nerding" width="300" height="300" /></img><br>
Click "Annie7.php"
<br><br><br><br>

Step 2: Permissions<br>
The ANNIE software needs to use the fasta file and Matlab program on your machine.<br>
It is <b>very</b> important to <u>adjust the permissions</u> on your machine (if necessary) to allow access to these files (Enable reading and writing)!<br>
Instructions of how to adjust those permissions for individual files can be found <a href="http://osxdaily.com/2011/02/21/change-file-permissions-mac/">Here!</a><br>
<i>Bear in mind: Sometimes, the permissions of parent folders will need to be adjusted <b>(such as the "Desktop" folder!)</b></i><br>
<img src="/pics/permissions.png" alt="permissions" width="300" height="300" /></img><br><br><br><br>

Step 3: Getting the filepaths of your files<br>
To get the file-paths to your fasta-file and matlab-file, right-click the files, select "Get Info", and copy the path after the label "Where:"<br>
When you enter this into the interface box on the web-page (labeled "Fasta File Path:"), <b>don't forget to type another "/", followed by the exact name of the file!</b>
For example:<br>
/Users/chris/Desktop/sequence_folder<b>/proteins.fasta</b><br><br>
The "matlab" program will be inside the Matlab directory (which is usually found in the "Applications" directory).<br>
The path may be something like:<br>
/Applications/MATLAB_R2010b.app/bin/matlab<br><br><br><br>

Step 4: Running the program<br>
Once the correct file-paths are in place, click the "Submit" button.<br>
If everything goes well, you should see some results, like this:<br>
<img src="/pics/results.png" alt="results" width="550" height="300" /></img><br>
The numbers represent the percent compositions of each amino acid found in each protein, and the isoelectric value of each protein.<br>
Check the folder your fasta file is in. It should contain two new files, which contain information about the function-predictions made by the ANNs<br><br><br><br>

Step 5: Interpreting the results<br>
Open the new CSV files in Excel (or any spreadsheet application).<br>
The first column shows the fasta-annotations of each protein. The rows which correspond to each protein, while the columns correspond to each group of ANNs which predicted the proteins.<br>
For example, the column which says "MCP_3:1" represents a group of 10 ANNs trained to differentiate between phage Major Capsid Proteins and non-Major Capsid Proteins.<br>
The "3:1" portion of the ANN name means that the ANNs were exposed to three times as many negative examples (non-MCPs) as positive examples (MCP), during its training.<br>
(An ANN trained with a high ratio of negative to positive examples will be less sensitive to an MCP, but will also be better able to predict non-MCPs)<br>
<img src="/pics/csv.png" alt="results" width="700" height="250" /></img><br>
The numbers are the average scores (from 10 ANNs), ranging from -1.0 to 1.0. A score less than 0 means the ANNs predict the protein is not a Major Capsid Protein,<br>
while a score greater than 0 means the ANNs predict the protein is a Major Capsid Protein. However, a number close to one or negative one represents a protein which the ANNs are more certain of<br>
than a number close to 0.



</FORM>
</html>
