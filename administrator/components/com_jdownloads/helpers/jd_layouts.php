<?php
/**
* @version 1.5
* @package JDownloads
* @copyright (C) 2009 www.jdownloads.com
* @license http://www.gnu.org/copyleft/gpl.html GNU/GPL
*
* 
*  Default layouts for jDownloads 1.8 and newer
*/

defined( '_JEXEC' ) or die( 'Restricted access' );

$COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_CATS_DEFAULT = '{cat_title_begin}<div style="background-color:#EFEFEF; padding:6px;">{subcats_title_text}</div>{cat_title_end}
{cat_info_begin}
<table width="100%" style="border-bottom: 1px solid #cccccc;">
  <tr valign="top" border="0px">
    <td width="75%" style="padding:5px;">{cat_pic}<b>{cat_title}</b></td>
    <td width="15%" style="padding:5px; text-align:right">{sum_subcats}</td>
    <td width="10%" style="padding:5px; text-align:right">{sum_files_cat}</td>
  </tr>
  <tr valign="top" border="0px">
    <td colspan="3" width="100%" style="padding:5px;">{cat_description}</td>
  </tr>
</table>
{cat_info_end}

<table border="0" cellspacing="2" cellpadding="5" width="100%" style=" background: #ffffff;">
{checkbox_top}
</table>
{files}
{form_hidden}
<div style="text-align:right">{form_button}</div>';

$COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT = '{files_title_begin}<div style="background-color:#EFEFEF; padding:6px;">
{files_title_text}</div>{files_title_end}

<table width="100%" border="0" cellpadding="5" cellspacing="5" style="background:#F8F8F8;border-bottom:1px solid #cccccc;">
     <tr valign="top">
        <td width="90%" valign="top">{file_pic} <b>{file_title}</b>
          {release} {pic_is_new} {pic_is_hot} {pic_is_updated}
        </td>
     </tr>
     <tr valign="top">
        <td valign="top" class="jd_body" width="90%">{screenshot_begin}<a href="{screenshot}" rel="lightbox"> <img src="{thumbnail}" align="right" vspace="0" hspace="10" alt="" /></a>{screenshot_end}{description}</td>
     </tr>
     <tr>
        <td valign="top" width="10%" align="center"></td>
     </tr>
     <tr>
        <td style="background:#F8F8F8; padding:5px;" valign="top" width="91%"><small>{license_text} {author_text} {author_url_text} {created_date_value} {language_text} {system_text} {filesize_value} {hits_value}</small></td>
        <td valign="top" width="9%" align="center">
            {checkbox_list}
        </td>
     </tr>
</table>';  

$COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_SUMMARY_DEFAULT = '<div class="jd_cat_title" style="padding:5px; font-size:10px; font-weight:normal;">{summary_pic} {title_text}</div>
<div valign="top" style="padding:5px;">{download_liste}</div>
<div style="padding:5px;">{aup_points_info}</div>
<div style="padding:5px; text-align:center;"><b>{license_title}</b></div>
<div>{license_text}</div>
<div style="text-align:center">{license_checkbox}</div>
<div style="text-align:center; padding:5px;">{download_link}</div>
<div style="text-align:center;">{info_zip_file_size}</div>
<div style="text-align:center;">{external_download_info}</div>
<div>{google_adsense}</div>';

$COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_DETAILS_DEFAULT = '<table width="100%" border="0" cellpadding="0" cellspacing="5">
    <tr>
       <td height="38" colspan="1" valign="top"><span style="font-size:13pt;">{file_pic} {file_title} {release} {pic_is_new} {pic_is_hot} {pic_is_updated}</span></td>
       <td></td>     
       <td>{rating}</td>
    </tr>
    <tr>
       <td width="313" height="370" valign="top">
        {screenshot_begin}<a href="{screenshot}" rel="lightbox" > <img src="{thumbnail}" align="right" vspace="0" hspace="10" alt="" /></a>{screenshot_end}
        {screenshot_begin2}<a href="{screenshot2}" rel="lightbox"> <img src="{thumbnail2}" align="right" vspace="0" hspace="10" alt="" /></a>{screenshot_end2}
        {screenshot_begin3}<a href="{screenshot3}" rel="lightbox"> <img src="{thumbnail3}" align="right" vspace="0" hspace="10" alt="" /></a>{screenshot_end3}
        {description_long}<br />{mp3_player}<br />{mp3_id3_tag}<br /></td>
       <td width="10" valign="top"></td>
       <td width="150" valign="top">
       <table width="100%" border="0" cellpadding="0" cellspacing="0" style="border-style:solid; border-width:thin; border-color:#CECECE; padding:5px; background-color:#EFEFEF;">
       <tr>
       <td height="25" colspan="2" valign="top">
           <p align="center" style="background-color:#CECECE; padding:2px;"><b>{details_block_title}</b></p>
       </td>
       </tr>
       <tr>
       <td height="20" valign="top">{filesize_title}</td>
       <td valign="top" style="text-align:right;">{filesize_value}</td>
       </tr>
       <tr>
        <td height="20" valign="top">{hits_title}</td>
        <td valign="top" style="text-align:right;">{hits_value}</td>
       </tr>
       <tr>
        <td height="20" valign="top">{language_title}</td>
        <td valign="top" style="text-align:right;">{language_text}</td>
       </tr>
       <tr>
        <td height="20" valign="top">{license_title}</td>
        <td valign="top" style="text-align:right;">{license_text}</td>
       </tr>
       <tr>
        <td height="20" valign="top">{author_title}</td>
        <td valign="top" style="text-align:right;">{author_text}</td>
       </tr>
       <tr>
        <td height="20" valign="top">{author_url_title}</td>
        <td valign="top" style="text-align:right;">{author_url_text}</td>
       </tr>
       <tr>
        <td height="20" valign="top">{price_title}</td>
        <td valign="top" style="text-align:right;">{price_value}</td>
       </tr>
       <tr>
        <td height="20" valign="top">{created_date_title}</td>
        <td valign="top" style="text-align:right;">{created_date_value}</td>
       </tr>
       <tr>
        <td height="20" valign="top">{created_by_title}</td>
        <td valign="top" style="text-align:right;">{created_by_value}</td>
       </tr>
       <tr>
        <td height="20" valign="top">{modified_date_title}</td>
        <td valign="top" style="text-align:right;">{modified_date_value}</td>
       </tr>
       <tr>
        <td height="20" valign="top">{modified_by_title}</td>
        <td valign="top" style="text-align:right;">{modified_by_value}</td>
       </tr>
       <tr>
        <td height="115" colspan="2" align="center" valign="middle">
        <p align="center"><font size="2">{url_download}</font><br />{mirror_1} {mirror_2}</p></td>
       </tr>
       </table>
    </td>
    </tr>
    <tr>
        <td></td>
        <td></td>
        <td align="center">{report_link}</td>
    </tr>
    </table>';

$COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_DETAILS_DEFAULT_WITH_TABS = '<table width="100%" border="0" cellpadding="0" cellspacing="5">
    <tr>
    <td height="38" colspan="3" valign="top"><span style="font-size:13pt;">{file_pic} {file_title} {release} {pic_is_new}{pic_is_hot}{pic_is_updated}</span></td><td><p style="text-align:right">{rating}</p></td>
  </tr>
</table>

{tabs begin}

{tab description}
<table width="100%" border="0" cellpadding="0" cellspacing="5">
    <tr>
    <td valign="top">{description_long}</td>
</tr></table>
{tab description end}

{tab pics}
<table align="center" cellpadding="4" cellspacing="1" border="0">
<tr><td>
{screenshot_begin}<a href="{screenshot}" rel="lightbox" > <img src="{thumbnail}" align="right" vspace="0" hspace="10" alt="" /></a>{screenshot_end} 
</td>
<td>
{screenshot_begin2}<a href="{screenshot2}" rel="lightbox" > <img src="{thumbnail2}" align="right" vspace="0" hspace="10" alt="" /></a>{screenshot_end2} 
</td>
<td>
{screenshot_begin3}<a href="{screenshot3}" rel="lightbox" > <img src="{thumbnail3}" align="right" vspace="0" hspace="10" alt="" /></a>{screenshot_end3} 
</td>
</tr></table>
{tab pics end}

{tab mp3}
{mp3_player}<br /><br />{mp3_id3_tag}
{tab mp3 end}

{tab data}
<table width="100%" border="0" cellpadding="0" cellspacing="3" style="border-style:solid; border-width:thin; border-color:#CECECE; padding:5px; background-color:#EFEFEF;">
      <tr>
       <td height="25" colspan="2" valign="top">
        <p align="center" style="background-color:#CECECE; padding:2px;"><b>{details_block_title}</b></p>
        </td>
      </tr>
      <tr>
        <td valign="top">{file_name_title}</td>
          <td valign="top" style="text-align:right;">{file_name}</td>
      </tr>
      <tr>
        <td valign="top">{filesize_title}</td>
          <td valign="top" style="text-align:right;">{filesize_value}</td>
      </tr>
      <tr>
        <td valign="top">{hits_title}</td>
          <td valign="top" style="text-align:right;">{hits_value}</td>
      </tr>
      <tr>
        <td valign="top">{language_title}</td>
          <td valign="top" style="text-align:right;">{language_text}</td>
      </tr>
      <tr>
        <td valign="top">{license_title}</td>
          <td valign="top" style="text-align:right;">{license_text}</td>
      </tr>
      <tr>
        <td valign="top">{author_title}</td>
          <td valign="top" style="text-align:right;">{author_text}</td>
      </tr>
      <tr>
        <td valign="top">{author_url_title}</td>
          <td valign="top" style="text-align:right;">{author_url_text}</td>
      </tr>
      <tr>
        <td valign="top">{price_title}</td>
          <td valign="top" style="text-align:right;">{price_value}</td>
      </tr>
      <tr>  
         <td valign="top">{created_date_title}</td>
          <td valign="top" style="text-align:right;">{created_date_value}</td>
      </tr>
      <tr>
        <td valign="top">{created_by_title}</td>
          <td valign="top" style="text-align:right;">{created_by_value}</td>
      </tr>
      <tr>
        <td valign="top">{modified_date_title}</td>
          <td valign="top" style="text-align:right;">{modified_date_value}</td>
      </tr>
      <tr>
        <td valign="top">{modified_by_title}</td>
          <td valign="top" style="text-align:right;">{modified_by_value}</td>
      </tr>
       </table>
{tab data end}

{tab download}
<table width="100%" border="0" cellpadding="0" cellspacing="5">
      <tr>
        <td height="20" align="center">{file_name_title}: {file_name}</td>
      </tr>
      <tr>
        <td height="20" align="center">{filesize_title}: {filesize_value}</td>
      </tr>
      <tr>
         <td align="center" valign="middle">{url_download} {mirror_1} {mirror_2}
         </td>
      </tr>
      <tr>
        <td height="20" align="center">{report_link}</td>
      </tr>
</table>
{tab download end}
{tab custom1}
<table width="100%" border="0" cellpadding="0" cellspacing="5">
<tr><td>{custom_title_1} {custom_value_1}</td></tr>
<tr><td>{custom_title_2} {custom_value_2}</td></tr>
<tr><td>{custom_title_3} {custom_value_3}</td></tr>
<tr><td>{custom_title_4} {custom_value_4}</td></tr>
<tr><td>{custom_title_5} {custom_value_5}</td></tr>
<tr><td>{custom_title_6} {custom_value_6}</td></tr>
<tr><td>{custom_title_7} {custom_value_7}</td></tr>
<tr><td>{custom_title_8} {custom_value_8}</td></tr>
<tr><td>{custom_title_9} {custom_value_9}</td></tr>
<tr><td>{custom_title_10} {custom_value_10}</td></tr>
<tr><td>{custom_title_11} {custom_value_11}</td></tr>
<tr><td>{custom_title_12} {custom_value_12}</td></tr>
<tr><td>{custom_title_13} {custom_value_13}</td></tr>
<tr><td>{custom_title_14} {custom_value_14}</td></tr>
</td></tr>
</table>
{tab custom1 end}
{tabs end}';    
    
    
$COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NEW_SIMPLE_1 = '{files_title_begin}<div style="background-color:#EFEFEF; padding:6px;">{files_title_text}</div>{files_title_end}

<table width="100%" style="padding:3px; background-color:#F5F5F5;">
   <tr>
      <td width="70%"> {file_pic} {file_title} {release} {pic_is_new} {pic_is_hot} {pic_is_updated}
      </td>
      <td width="20%">
          <p align="center">{rating}</p>
      </td>
      <td width="10%">
          <p align="center">{checkbox_list}</p>
      </td>
   </tr>
</table>
<table width="100%" style="padding:3px;">    
   <tr>
      <td width="70%" align="left" valign="top" colspan="3">{screenshot_begin}<a href="{screenshot}" rel="lightbox"> <img src="{thumbnail}" align="right" vspace="0" hspace="10" alt="" /></a>{screenshot_end}{description}<br />{mp3_player}<br />{mp3_id3_tag}<br /><br />
      </td>
      <td width="10%" valign="top">{created_date_title}<br />{filesize_title}<br />{hits_title}</td>
      <td width="20%" valign="top">{created_date_value}<br />{filesize_value}<br />{hits_value}</td>
   </tr>
   <tr><td> </td>
   </tr>
</table>';

$COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NEW_SIMPLE_2 = '{files_title_begin}<div style="background-color:#EFEFEF; padding:6px;">{files_title_text}</div>{files_title_end}

<table width="100%" style="padding:3px; background-color:#F5F5F5;">
   <tr>
      <td width="70%"> {file_pic} {file_title} {release} {pic_is_new} {pic_is_hot} {pic_is_updated}         
      </td>
      <td width="15%">
          <p align="center">{rating}</p>
      </td>
      <td width="15%">
          <p align="center">{url_download}</p>
      </td>
   </tr>
</table>
<table width="100%" style="padding:3px;">    
  <tr>
     <td width="70%" align="left" valign="top" colspan="3">{screenshot_begin}<a href="{screenshot}" rel="lightbox"> <img src="{thumbnail}" align="right" vspace="0" hspace="10" alt="" /></a>{screenshot_end}{description}<br />{mp3_player}<br />{mp3_id3_tag}<br />
     </td>
     <td width="10%" valign="top">{created_date_title}<br />{filesize_title}<br />{hits_title}</td>
     <td width="20%" valign="top">{created_date_value}<br />{filesize_value}<br />{hits_value}</td>
  </tr>
  <tr>
     <td></td>
  </tr>
</table>';

$COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NEW_SIMPLE_3 = '{files_title_begin}
<div style="background-color:#EFEFEF; border:1px solid #BFBFBF; padding:6px;">{files_title_text}</div>
<table width="100%" border="0" cellpadding="6" cellspacing="0" style="background:#EBEBEB;border-left:1px solid #cccccc; ;border-bottom:1px solid #cccccc;border-right:1px solid #cccccc"">
  <tr>
  <td width="45%">Name</td>
  <td style="border-left:1px solid #BFBFBF;" align="center" width="20%">{created_date_title}</td>
  <td style="border-left:1px solid #BFBFBF;" align="center" width="15%">{filesize_title}</td>
  <td style="border-left:1px solid #BFBFBF;" align="center" width="10%">{hits_title}</td>
  <td style="border-left:1px solid #BFBFBF;" align="center" width="10%">&nbsp;&nbsp;&nbsp;</td>
  </tr>
</table>
{files_title_end}

<table width="100%" border="0" cellpadding="6" cellspacing="0" style="background:#F8F8F8;border-bottom:1px solid #cccccc;border-right:1px solid #cccccc">
   <tr><td style="border-left:1px solid #cccccc;"font: bold width="45%" valign="center">{file_pic} {file_title} {release}</td>
   <td style="border-left:1px solid #cccccc;" align="center" width="20%"><small> {created_date_value}</small></td>
   <td style="border-left:1px solid #cccccc;" align="center" width="15%"><small>{filesize_value}</small></td>
   <td style="border-left:1px solid #cccccc;" align="center" width="10%"><small>{hits_value}</small></td>
   <td style="border-left:1px solid #cccccc;" align="center" width="10%"><small>{url_download}</small></td>
</tr>
</table>';

$COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_CATS_COL_DEFAULT = '{cat_title_begin}<div style="background-color:#EFEFEF; padding:6px;">{subcats_title_text}</div>{cat_title_end}
{cat_info_begin}
  <table width="100%">
    <tr valign="top" border="0px">
      <td width="25%" style="padding:5px; text-align:center">{cat_pic1}<b><br />{cat_title1}</b><br />{sum_subcats1}<br />{sum_files_cat1}</td>
      <td width="25%" style="padding:5px; text-align:center">{cat_pic2}<b><br />{cat_title2}</b><br />{sum_subcats2}<br />{sum_files_cat2}</td>
      <td width="25%" style="padding:5px; text-align:center">{cat_pic3}<b><br />{cat_title3}</b><br />{sum_subcats3}<br />{sum_files_cat3}</td>
      <td width="25%" style="padding:5px; text-align:center">{cat_pic4}<b><br />{cat_title4}</b><br />{sum_subcats4}<br />{sum_files_cat4}</td>
    </tr>
  </table>
{cat_info_end}
<table border="0" cellspacing="2" cellpadding="5" width="100%" style=" background: #ffffff;">
{checkbox_top}
</table>
{files}
{form_hidden}
<div style="text-align:right">{form_button}</div>';

#Standard Layout for MP3 ID3 Tags
$COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_ID3TAG = '<table width="300px" style="padding:5px; background-color:#FFFFDD;">
<tr>
  <td width="80px">{album_title}:</td>
  <td width="220px">{album}</td>
</tr>
<tr>
  <td width="80px">{name_title}:</td>
  <td width="220px">{name}</td>
</tr>
<tr>
  <td width="80px">{year_title}:</td>
  <td width="220px">{year}</td>
</tr>
<tr>
  <td width="80px">{artist_title}:</td>
  <td width="220px">{artist}</td>
</tr>
<tr>
  <td width="80px">{genre_title}:</td>
  <td width="220px">{genre}</td>
</tr>
<tr>
  <td width="80px">{length_title}:</td>
  <td width="220px">{length}</td>
</tr>
</table>';

$cats_header = '<div class="componentheading">{component_title}</div>
<table class="jd_top_navi" width="100%" style="border-bottom: 1px solid #cccccc;">
<tr valign="top" border="0px">
<td style="padding:5px;">{home_link}</td>
<td style="padding:5px;">{search_link}</td>
<td style="padding:5px;">{upload_link}</td>
<td style="padding:5px;" align="right" valign="bottom">{category_listbox}</td>
</tr>
</table>';

$cats_subheader = '<table class="jd_cat_subheader" width="100%">
<tr>
<td width="45%" valign="top">
<b>{subheader_title}</b>
</td>
<td width="55%" valign="top" colspan="2">
<div class="jd_page_nav" style="text-align:right">{page_navigation_pages_counter} {page_navigation}</div>
</td>
</tr>
<tr>
<td width="45%" valign="top" align="left">{count_of_sub_categories}</td>
<td width="55%" valign="top" colspan="2"></td>
</tr>
</table>';

$cats_footer = '<table class="jd_footer" align="right" width="100%">              
<tr>
<td width="70%" valign="top"></td>
<td width="30%" valign="top">
<div class="jd_page_nav" style="text-align:right">{page_navigation}</div>
</td>
</tr>
</table>
<div style="text-align:left" class="back_button">{back_link}</div>';

$files_header = '<div class="componentheading">{component_title}</div>
<table class="jd_top_navi" width="100%" style="border-bottom: 1px solid #cccccc;">
<tr valign="top" border="0px">
<td style="padding:5px;">{home_link}</td>
<td style="padding:5px;">{search_link}</td>
<td style="padding:5px;">{upload_link}</td>
<td style="padding:5px;">{upper_link}</td>
<td style="padding:5px;" align="right" valign="bottom">{category_listbox}</td>
</tr>
</table>';

$files_subheader = '<table class="jd_cat_subheader" width="100%">
<tr>
<td width="45%" valign="top">
<b>{subheader_title}</b>
</td>
<td width="55%" valign="top" colspan="2">
<div class="jd_page_nav" style="text-align:right">{page_navigation_pages_counter} {page_navigation}</div>
</td>
</tr>
<tr>
<td width="45%" valign="top" align="left">{count_of_sub_categories}</td>
<td width="55%" valign="top" colspan="2">
<div class="jd_sort_order" style="text-align:right">{sort_order}</div>
</td>
</tr></table>';

$files_footer = '<table class="jd_footer" align="right" width="100%">              
<tr>
<td width="100%" valign="top">
<div class="jd_page_nav" style="text-align:right">{page_navigation}</div>
</td>
</tr>
</table>
<div style="text-align:left" class="back_button">{back_link}</div>';

$details_header = '<div class="componentheading">{component_title}</div>
<table class="jd_top_navi" width="100%" style="border-bottom: 1px solid #cccccc;">
<tr valign="top" border="0px">
<td style="padding:5px;">{home_link}</td>
<td style="padding:5px;">{search_link}</td>
<td style="padding:5px;">{upload_link}</td>
<td style="padding:5px;">{upper_link}</td>
<td style="padding:5px;" align="right" valign="bottom">{category_listbox}</td>
</tr>
</table>';

$details_subheader = '<table class="jd_cat_subheader" width="100%">
<tr><td><b>{detail_title}</b></td></tr>
</table>';

$details_footer = '<div style="text-align:left" class="back_button">{back_link}</div>';

$summary_header = '<div class="componentheading">{component_title}</div>
<table class="jd_top_navi" width="100%" style="border-bottom: 1px solid #cccccc;">
<tr valign="top" border="0px">
<td style="padding:5px;">{home_link}</td>
<td style="padding:5px;">{search_link}</td>
<td style="padding:5px;">{upload_link}</td>
<td style="padding:5px;">{upper_link}</td>
<td style="padding:5px;" align="right" valign="bottom">{category_listbox}</td>
</tr>
</table>';

$summary_subheader = '<table class="jd_cat_subheader" width="100%">
<tr><td><b>{summary_title}</b></td></tr>
</table>';

$summary_footer = '<div style="text-align:left" class="back_button">{back_link}</div>';

$COM_JDOWNLOADS_BACKEND_SETTINGS_TEMPLATES_FILES_DEFAULT_NEW_SIMPLE_3_NAME = 'Simple Files List';
?>