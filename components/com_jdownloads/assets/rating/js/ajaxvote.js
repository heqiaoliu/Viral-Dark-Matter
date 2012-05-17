/*
// "AJAX Vote" Plugin for Joomla! 1.0.x - Version 1.1
// License: http://www.gnu.org/copyleft/gpl.html
// Authors: George Chouliaras - Fotis Evangelou - Luca Scarpa
// Copyright (c) 2006 - 2007 JoomlaWorks.gr - http://www.joomlaworks.gr
// Project page at http://www.joomlaworks.gr - Demos at http://demo.joomlaworks.gr
// ***Last update: October 25th, 2007***
// modified for jdownloads by Arno Betz - www.jdownloads.com
*/

function jwAjaxVote(id,i,total,total_count){
	var lsXmlHttp;
	var div = document.getElementById('jwajaxvote'+id);
    div.innerHTML='<img src="'+live_site+'components/com_jdownloads/assets/rating/images/loading.gif" border="0" align="absmiddle" /> '+jwajaxvote_lang['UPDATING'];
	try	{
		lsXmlHttp=new XMLHttpRequest();
	} catch (e) {
		try	{ lsXmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) {
			try { lsXmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
			} catch (e) {
				alert("Your browser does not support AJAX!");
				return false;
			}
		}
	}
	lsXmlHttp.onreadystatechange=function() {
		var response;
		if(lsXmlHttp.readyState==4){
			setTimeout(function(){ 
				response = lsXmlHttp.responseText; 
				if(response=='1') div.innerHTML=jwajaxvote_lang['THANKS'];
				else div.innerHTML=jwajaxvote_lang['ALREADY_VOTE'];
			},500);
			setTimeout(function(){
				if(response=='1'){
					var newtotal = total_count+1;
					if(newtotal!=1)	div.innerHTML='('+(newtotal)+' '+jwajaxvote_lang['VOTES']+')';
					else div.innerHTML='('+(newtotal)+' '+jwajaxvote_lang['VOTE']+')';
					var percentage = ((total + i)/(newtotal))*20;
					document.getElementById('rating'+id).style.width=percentage+'%';
				} else {
					if(total_count!=1)	div.innerHTML='('+(total_count)+' '+jwajaxvote_lang['VOTES']+')';
					else div.innerHTML='('+(total_count)+' '+jwajaxvote_lang['VOTE']+')';
				}
			},2000);
		}
	}
	lsXmlHttp.open("GET",live_site+"components/com_jdownloads/assets/rating/ajax.php?task=vote&user_rating="+i+"&cid="+id,true);
	lsXmlHttp.send(null);			
}