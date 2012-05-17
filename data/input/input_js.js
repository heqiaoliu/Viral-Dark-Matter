$(function() {

    // radio_bact -> bactid radio button
    $radio_bact = $('input#radio_bact');
    // radio_vcid -> vcid radio button
    $radio_vcid = $('input#radio_vcid');  

    /*
    * MUTUAL EXCLUSION VCID, BACT ID with RADIO BUTTON
    ***/
    $radio_bact.click(function(){
        // If bactid radio is checked, uncheck vcid radio and reenable bactid
        if($radio_bact.is(':checked')) {
            $radio_vcid.attr('checked', false);
            $('#vcid').attr('disabled', 'disabled');
            $('#bactid').removeAttr('disabled');
            // Use the current bactid to pull vcid from DB
            // Send bactid to vbselect
            vbselect('bact_id&bact_id='+$('#bactid').val());
        } else {
            $radio_bact.attr('checked');
        }
    });
    $('#bactid').change(function() {
        vbselect('bact_id&bact_id='+$('#bactid').val());
    }); 
        
    /*
    * MUTUAL EXCLUSION VCID, BACT ID with RADIO BUTTON
    ***/
    $radio_vcid.click(function(){
        // If vcid radio is checked, uncheck bactid radio and reenable vcid
        if($radio_vcid.is(':checked')) {
            $radio_bact.attr('checked', false);
            $('#bactid').attr('disabled', 'disabled');
            $('#vcid').removeAttr('disabled');
            // Use the current vcid to pull vcid from DB
            // Send vcid to vbselect
            vbselect('vc_id&vc_id='+$('#vcid').val());
        } else {
            $radio_vcid.attr('checked'); 
       }
    });

    $('#vcid').change(function() {
        vbselect('vc_id&vc_id='+$('#vcid').val());
    });

    /*
    * AJAX CHECK DB FOR FILENAME WHEN FILE IS SELECTED.  
    ***/
    $('#uploadedfile').change(function(){
        $this = $(this).val();
        var datastring = escape($this);
        datastring = "file="+datastring;
        // Set overwrite to no to prevent the following likely situation: A user decides to upload a file again, clicks 'yes' for overwrite, then changes her mind and selects a different file
        $('#overwrite').val('no');
        //console.log(datastring+"\n");
        $.ajax({
            type: "POST",
            url: "input_filecheck.php",
            data: datastring,
            dataType: "text",
            success: function(data) {
                // display message back to user here
                console.log(data);
                $perror = $('p#error');
                switch(data) {
                    case "success":
                        $perror.html('');
                        break;
                    case "error1":
                        $perror.html('Cannot open connection to database at edwards.sdsu.edu. Unable to verify file.  Please try again later.');
                        break;
                    case "error2":
                        $perror.html('Cannot select database viral_dark_matter. Unable to verify file.  Please try again later.');
                        break;
                    case "error3":
                        $perror.html('Cannot execute the query on the database. Unable to verify file.  Please try again later.');
                        break;
                    case "error4":
                        $perror.html('This file has already been uploaded. Overwrite current data? <input type="submit" id="dontcare" value="Continue Anyway">&nbsp;<input type="submit" id="icare" value="cancel">');
                        $('#upload').attr('disabled', true);
                        $('#dontcare').click(function(){
                            // This function should set a flag so that when the duplicate file is uploaded (i.e. when the user clicks upload) the original data from the file should be deleted
                            $('#overwrite').attr('value', 'yes');
                            $perror.html('');
                            $('#upload').removeAttr('disabled');
                        });
                        $('#icare').click(function(){
                            // This function should set a flag so that when the duplicate file is uploaded (i.e. when the user clicks upload) the original data from the file should be deleted
                            $('#overwrite').attr('value', 'no');
                            $perror.html('');
                            $('#uploadedfile').trigger('click');
                            $('#uploadedfile').trigger('change');
                            $('#upload').removeAttr('disabled');
                        });
                        break;
                }
            },
            error: function() {
                $('p#error').html('AJAX connection error: Unable to verify file.  Please try again later.  ');
            }
        });
    });
});

/*
* Automatically select the other item (VCID or BACTID).  AJAX call to input_vbselect.php which accesses database.
***/
function vbselect(id) {
    var datastring = "id="+id;
    //console.log(datastring);
    $.ajax({
        type: "POST",
        url: "input_vbselect.php",
        data: datastring,
        dataType: "text",
        success: function(data) {
            //display message back to user here
            //console.log(data+"...\n");
            myregexp = /^success.*/;

            if (data.match(myregexp)) {
                data = data.substring(8);
                $('#other').val(data);
            }
            //console.log(data+".+.\n");
            otherselect();
            $perror = $('p#error');
            switch(data) {
                case "success":
                    $perror.html('');
                    $('#other').val(data);
                    break;
                case "error1":
                    $perror.html('Cannot open connection to database at edwards.sdsu.edu.  Please try again later.');
                    break;
                case "error2":
                    $perror.html('Cannot select database viral_dark_matter.  Please try again later.');
                    break;
                case "error3":
                    $perror.html('Cannot execute the query on the database.  Please try again later.');
                    break;
                case "error4":
                    $perror.html('There is no corresponding VCID or BACTID.');
                    break;
            }
        },
        error: function() {
            $('p#error').html('AJAX connection error: Unable to verify find corresponding VCID or BACTID.  Please try again later.  ');
        }
    });
}

// When the vcid or bactid is returned, and is put in the hidden <input id="other">, set the other one (bactid or vcid) :-)
function otherselect() {
    //console.log("other.change");
    $radio_bact = $('input#radio_bact');
    $oval = $('#other').val();
    if($radio_bact.is(':checked')) {
        // bactid is checked
        $('#vcid').val($oval);
    } else {
        // vcid is checked
        $('#bactid').val($oval);
    }
}
/*
// input id="upload" type="submit" value="Upload File" 
$(function(){
    $("input#upload").click(function(){
        alert("before post");
        $.post('input_uploader_test.php', $("#inputUploadForm").serialize(), function(data) {
            $('p#success').html(data);
            console.log(data);
            alert("success");
        });
    });
});
*/
