/**
 * ------------------------------------------------------------------------
 * JA T3 System plugin for Joomla 1.7
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-2011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

var JAT3_PAGEIDSETTINGS = new Class({

    Implements: Options,

    options: {
        param_name:         null,
        page_select:        null,
        theme_select:       null,
        active_pop_in:      0,
        obj_theme_select:   null,
        max_row_added:      0  // maximum number was increase each time addrow
    },

    initialize: function(options) {
        this.setOptions(options);
    },

    choosePageids: function(obj, k) {
        obj = $(obj);
        if (!typeOf(k)) {
            k = this.options.page_select;
        }

        // Close profile popup
        this.close_popup(this.options.param_name + '-ja-popup-profiles');
        // Get selection row
        this.options.page_select = parseInt(k);

        // Get values
        var values = obj.get('text').trim();
        // Set default language
        var language = '';
        // Split language and pageids
        var selected = values.split('/');
        if (selected.length > 1) {
            language = selected[0].clean();
            selected = selected[1].split(',');
        } else {
            language = selected[0].clean();
            if (language == '') {
                language = 'All';
            }
            selected = [];
        }
        // Split pages into array
        for(var i=0; i < selected.length; i++){
            // Clean each data
            selected[i] = selected[i].clean();
        }
        // Get all page item
        var pageitems = $('page-assignment-list').getElements('input.pageitem');
        // Get all item was selected
        var selected_pages = this.getSelectedPages(language);
        // Check each page item
        // If it was select in other row, check and disable it
        // If it was select in selected row, check and enable it
        for (var i = 0, n = pageitems.length; i < n; i++) {
            pageitems[i].checked = false;
            pageitems[i].disabled = false;
            if (selected_pages.contains(pageitems[i].id)) {
                pageitems[i].checked = true;
                pageitems[i].disabled = true;
            }
            if (selected.contains(pageitems[i].id)) {
                pageitems[i].checked = true;
                pageitems[i].disabled = false;
            }
        }

        // Select language
        var langEl = $(this.options.param_name + '-ja-popup-pageids').getElement('.ja-language');
        if (langEl) {
            var options = langEl.options;
            for (i = 0, n = options.length; i < n; i++) {
                if (language == options[i].value.trim()) {
                    options[i].selected = true;
                    break;
                }
            }
        }
        // Show popup
        this.setPosition_for_poup($(this.options.param_name + '-ja-popup-pageids'), obj);
        this.options.active_pop_in = 0;

        return;
    },

    chooseProfile: function(obj, k) {
        obj = $(obj);
        if (typeOf(k)) {
            this.options.theme_select = k;
        } else {
            k = this.options.theme_select;
        }
        // Close pageid popup
        this.close_popup(this.options.param_name + '-ja-popup-pageids');
        this.options.obj_theme_select = obj;
        // Get selected item
        var selected   = obj.get('text').trim().toLowerCase();
        // Get all profile item
        var selections = $$('#' + this.options.param_name + '-ja-popup-profiles li');
        // Check and set active item
        for (var i = 0, n = selections.length; i < n; i++) {
            selections[i].removeClass('active');
            if (selections[i].get('text').trim().toLowerCase() == selected ) {
                selections[i].addClass('active');
            }
        }

        this.options.active_pop_in = 0;
        this.setPosition_for_poup($(this.options.param_name + '-ja-popup-profiles'), obj);
    },

    add_chooseProfile: function(obj, k) {
        obj = $(obj);
        this.chooseProfile(obj, k);
        obj.setOpacity('1');
    },

    setPosition_for_poup: function(popup_obj, position_obj) {
        var position = position_obj.getPosition();
        var height = position_obj.offsetHeight;
        popup_obj.setStyles({top: position.y + height, left: position.x, display:'block'});
    },

    close_popup: function(divid) {
        $(divid).setStyle('display', 'none');
    },

    select_multi_pageids: function() {
        // Close popup first
        this.close_popup(this.options.param_name + '-ja-popup-pageids');
        // Get language element
        var langEl = $(this.options.param_name + '-ja-popup-pageids').getElement('.ja-language');
        // Get language
        var selectedLang = 'All';
        if (langEl) {
            selectedLang = langEl.options[langEl.selectedIndex].value;
        }
        // Get selected pages
        var selections = $('page-assignment-list').getElements('input:checked:enabled');
        var selected   = [];
        for (var i = 0; i < selections.length; i++) {
            selected.push(selections[i].id);
        }
        // Join them
        selected = selected.join(', ');
        // If language isn't all, append it with selected pages
        if (selectedLang != 'All' || selected.length > 0) {
            if (selected.length > 0) {
                selected = selectedLang + ' / ' + selected;
            } else {
                selected = selectedLang;
                // Get assigned rows
                var rows = $(this.options.param_name + '-ja-list-pageids').getElements('.ja-item');
                var tmp  = '';
                // Check there is duplicate selected language
                // If there is, not select it
                for (i = 1, n = rows.length; i < n; i++) {
                    tmp = rows[i].getElement('.pageid_text').get('text').trim();
                    // Split language & pages
                    tmp = tmp.split('/');
                    if (tmp.length == 1) {
                        // Get language
                        tmp = tmp[0].trim();
                        if (tmp == selectedLang) {
                            selected = '';
                            break;
                        }
                    }
                }
            }
        }
        if (parseInt(this.options.page_select) > -1 && selected != '') {
            var row    = $(this.options.param_name + '-row-' + this.options.page_select);
            var pageid = row.getElement('.pageid_text');
            pageid.set('text', selected);
            pageid.removeClass('more');
            this.buildData_of_param();
        }
    },

    select_profile: function(obj) {
        obj = $(obj);
        var value = obj.get('text').trim();
        this.close_popup(this.options.param_name + '-ja-popup-profiles');

        if (obj.getParent().className.indexOf('active') > -1){
            return;
        }

        this.options.obj_theme_select.removeClass('active');
        if (parseInt(this.options.theme_select) > -1 && value != '') {
            var new_el = this.options.obj_theme_select;
            new_el.set('text',value);
            new_el.setStyle('display', 'inline');
            new_el.removeClass('more');
            $('ja-tabswrap').getElement('li.general').addClass('changed');
            this.buildData_of_param();
        }
    },

    /**
     * Add a row when use click last row
     */
    addrow: function (obj) {
        obj = $(obj);
        var table = $(this.options.param_name + '-ja-list-pageids');
        // Check max_row_added
        if (this.options.max_row_added == 0) {
            this.options.max_row_added = table.rows.length + 1;
        } else {
            this.options.max_row_added += 1;
        }
        // Get row index
        var k = this.options.max_row_added - 1;

        this.options.page_select = k;
        this.options.theme_select = k;

        // Clone last row
        var last = table.rows[table.rows.length - 1];
        var li = $(last).clone();

        li.injectAfter(last);
        last.set({'id': this.options.param_name + '-row-'+k });
        last.getElement('span.pageid_text').innerHTML = '&nbsp';

        // Add event for pageids cell
        var  args = new Array(last.getElement('span.pageid_text'), k);
        last.getElement('span.pageid_text').addEvent('click', this.choosePageids.pass(args, this));
        // Add event for profile cell
        args = new Array(last.getElement('span.profile_text'), k);
        last.getElement('span.profile_text').addEvent('click', this.add_chooseProfile.pass(args, this));
        // ???
        last.getElement('span.ja_close').addEvent('click', this.removerow.bind(this, last.getElement('span.ja_close')));

        // Check if first cell, show pageids popup
        if (obj == last.getFirst()) {
            this.choosePageids(obj.getElement('span.pageid_text'), k);
        }
        //if (obj == last.getChildren()[1]) {
        //    this.add_chooseProfile(obj.getElement('span.profile_text'), k);
        //}

        // Set opacity for new added row
        obj.getFirst().setOpacity(1);
        obj.getNext().getFirst().setOpacity(1);
        //obj.getNext().getNext().getFirst().setOpacity(1);
        //obj.getNext().getNext().getNext().getElement('img').setOpacity(1);
        obj.getNext().getNext().getElement('img').setOpacity(1);

        last.setOpacity('1');
        last.getElement('span.ja_close').setStyle('display', '');
        last.getFirst().onclick = function() {
            void(0);
        };
        last.getChildren()[1].onclick = function() {
            void(0);
        };

        if (typeOf(jatabs)) {
            jatabs.resize();
        }

    },

    /**
     * Remove a row when user click remove icon
     */
    removerow: function (obj){
        if (confirm(lg_confirm_delete_assignment)) {
            obj = $(obj);
            $(obj.parentNode.parentNode).destroy();
            this.buildData_of_param();
        }
    },

    /**
     * Build data from assigned pages
     */
    buildData_of_param: function () {
        // Get element store data
        var params = $(this.options.param_name + '-profile');
        params.value = '';
        // Get list of element row that content assigned pages
        var els = $(this.options.param_name+'-ja-list-pageids').getElements('tr.ja-item');
        var length = els.length - 1;

        // Check each row
        els.each(function (el, i) {
            var pageid   = el.getElement('span.pageid_text').get('text').trim();
            var profile  = el.getElement('span.profile_text').get('text').trim();
            var language = 'All';
            if (profile != '' && pageid != '') {
                if (i == 0) {
                    // If first row, assignment page is default
                    params.value += 'all';
                } else {
                    if (pageid != '') {
                        // If user assigned one page more more, need to merge it with language
                        var pages = pageid.split('/');
                        if (pages.length > 1) {
                            language = pages[0].clean();
                            // If there are pages were selected, split it. Otherwise, assign page to empty array
                            pages[1] = pages[1].clean();
                            if (pages[1].length > 0) {
                                pages = pages[1].split(',');
                            } else {
                                pages = [];
                            }
                        } else {
                            language = pages[0].clean();
                            pages    = [];
                        }
                        // Join language with pageid
                        // Note: Do not join language with pageid if language = default
                        if (language != 'All') {
                            // If there are pages were selected, append language with them
                            if (pages.length > 0) {
                                for (var j = 0, n = pages.length; j < n; j++) {
                                    pages[j] = language + '#' + pages[j].clean();
                                }
                            } else {
                                // If pages were selected, append only language
                                pages.push(language);
                            }
                        }
                        params.value += pages.join(',');
                    } else {
                        // If user didn't assign any page, consider as user want assign only language
                        params.value += language;
                    }
                }
                params.value += '=' + profile;
                if (i < length) {
                    params.value += '\n';
                }
            }
        });
    },

    /**
     * ???
     */
    deleteTheme: function (obj){
        obj = $(obj);
        $(obj).getPrevious().destroy();
        $(obj).destroy();
        this.buildData_of_param();
    },

    /**
     * Get selected pages in a language
     */
    getSelectedPages: function(language, excludeRow) {
        // Get page assignment rows
        var rows = $$('.ja-list-pageids tr.ja-item');
        var rLang = '', rPageids = '', tmp;
        var pageids = [];
        // Get assignment pages of language
        for (var i = 1, n = rows.length; i < n; i++) {
            // Continue if exclude row
            if (excludeRow != undefined && rows[i] == excludeRow) continue;
            // Split language & pageids
            rPageids = rows[i].getElement('.pageid_text').get('text').trim();
            tmp = rPageids.split('/');
            if (tmp.length > 1) {
                rLang = tmp[0].clean();
                rPageids = tmp[1];
            } else {
                rLang = tmp[0].clean();
                if (rLang == '') {
                    rLang = 'All';
                }
                rPageids = '';
            }
            // Check row has language same language in current selected row
            if (rLang == language) {
                tmp = pageids.concat(rPageids.split(','));
                for (var j = 0, m = tmp.length; j < m; j++) {
                    if (tmp[j].clean() != '') {
                        pageids.push(tmp[j].clean());
                    }
                }
            }
        }
        return pageids;
    },

    /**
     * Clear data when user click outsite page assingment
     */
    clearData: function() {
        // Close popup menu
        if (this.options.active_pop_in == 1) {
            $(this.options.param_name + '-ja-popup-profiles').setStyle('display', 'none');
            $(this.options.param_name + '-ja-popup-pageids').setStyle('display', 'none');
            //this.options.active_pop_in = 0;
        }
        this.options.active_pop_in = 1;
        //  Remove active row of profile popup
        if (parseInt(this.options.theme_select) > -1 &&
            $type($(this.options.param_name + '-row-' + this.options.theme_select)) &&
            $type($(this.options.param_name + '-row-' + this.options.theme_select).getElement('span.active'))
        ) {
            $(this.options.param_name + '-row-' + this.options.theme_select).getElement('span.active').removeClass('active');
        }
        // Reset data store in select language
        var langObj = $('ja-language');
        var langOps = langObj.options;
        for (var i = 0, n = langOps.length; i < n; i++) {
            langObj.store(langOps[i].value, []);
        }
    },

    focusLanguage: function(obj) {
        obj = $(obj);
        var data = [];
        // Store selection items
        var items = $('page-assignment-list').getElements('input.pageitem');
        for (var i = 0, n = items.length; i < n; i++) {
            if (items[i].disabled == false && items[i].checked == true) {
                data.push(items[i].id);
            }
        }
        obj.store(obj.value, data);
    },
    /**
     * Re-selected pages when language changed
     */
    changeLanguage: function(obj) {
        obj = $(obj);
        var preData = obj.retrieve(obj.value, []);
        var name = this.options.param_name;
        var k = this.options.page_select;
        var curRow = $(name + '-row-' + k).getElement('.pageid_text');
        var curLang = curRow.get('text');
        curLang = curLang.split('/');
        if (curLang.length > 0) {
            curLang = curLang[0].trim();
        }
        // Get language
        var language = obj.options[obj.selectedIndex].value.trim();
        if (curLang != language) {
            // Get all page item
            var pageitems = $('page-assignment-list').getElements('input.pageitem');
            // Get all item was selected
            var selected_pages = this.getSelectedPages(language);
            // Check each page item
            for (var i = 0, n = pageitems.length; i < n; i++) {
                pageitems[i].checked = false;
                pageitems[i].disabled = false;
                if (selected_pages.contains(pageitems[i].id)) {
                    pageitems[i].checked = true;
                    pageitems[i].disabled = true;
                }
                // Check all checked previous
                if (preData.contains(pageitems[i].id)) {
                    pageitems[i].checked = true;
                }
            }
        } else {
            this.choosePageids(curRow, k);
            // Get all items
            var pageitems = $('page-assignment-list').getElements('input.pageitem');
            for (var i = 0, n = pageitems.length; i < n; i++) {
                // Check all checked previous
                if (preData.contains(pageitems[i].id)) {
                    pageitems[i].checked = true;
                }
            }
        }
    },

    /**
     * Build element of pages become treeview
     */
    buildPageAssignmentList : function() {
        this.selected = [];
        var page = $("page-assignment-list");
        if (page) {
            // Build menu tree from li tag
            this.buildTree = function(li) {
                if (li.getElements('ul').length > 0){
                    //var ul = li.getElementsByTagName("ul")[0];
                    var ul = li.getFirst('ul');
                    ul.style.display = 'none';
                    //var span = document.createElement("span");
                    var span = new Element('span');
                    span.className = "collapsed";
                    span.addEvent('click', function() {
                        ul.style.display = (ul.style.display == "none") ? "block" : "none";
                        this.className = (ul.style.display == "none") ? "collapsed" : "expanded";
                    });
                    li.appendChild(span);
                }
            };
            // Build tree menu
            var items = page.getElements("li");
            for (var i = 0; i < items.length; i++) {
                this.buildTree(items[i]);
            }
            // Set event click of input tag
            var items = page.getElements('ul.lang input.pageitem');
            if (items.length == 0) {
                items = page.getElements('input.pageitem');
            }
            var eventName = 'change';
            if (Browser.ie) eventName = 'click';
            for (var i = 0; i < items.length; i++) {
                items[i].addEvent(eventName, function() {
                    var ul = this.getParent().getElement('ul');
                    if (ul) {
                        var subitems = ul.getElements('input.pageitem');
                        for (var j = 0; j < subitems.length; j++) {
                            if (!subitems[j].disabled) {
                                subitems[j].checked = this.checked;
                            }
                        }
                    }
                });
            }

        }
    }
});

