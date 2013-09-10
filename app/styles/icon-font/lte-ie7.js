/* Load this script using conditional IE comments if you need to support IE 7 and IE 6. */

window.onload = function() {
	function addIcon(el, entity) {
		var html = el.innerHTML;
		el.innerHTML = '<span style="font-family: \'swipes\'">' + entity + '</span>' + html;
	}
	var icons = {
			'icon-triangle-right' : '&#xe000;',
			'icon-triangle-left' : '&#xe001;',
			'icon-trashcan' : '&#xe002;',
			'icon-todo' : '&#xe003;',
			'icon-tags' : '&#xe004;',
			'icon-swipes-plus' : '&#xe005;',
			'icon-swipes-logo' : '&#xe006;',
			'icon-swipes-logo-square' : '&#xe007;',
			'icon-support' : '&#xe008;',
			'icon-snooze-unspecified' : '&#xe009;',
			'icon-snooze-tomorrow' : '&#xe00a;',
			'icon-snooze-this-weekend' : '&#xe00b;',
			'icon-snooze-this-evening' : '&#xe00c;',
			'icon-snooze-next-week' : '&#xe00d;',
			'icon-snooze-location' : '&#xe00e;',
			'icon-snooze-later-today' : '&#xe00f;',
			'icon-snooze-day-after-tomorrow' : '&#xe010;',
			'icon-snooze-date' : '&#xe011;',
			'icon-share' : '&#xe012;',
			'icon-schedule' : '&#xe013;',
			'icon-repeat' : '&#xe014;',
			'icon-questionmark-circle' : '&#xe015;',
			'icon-policy' : '&#xe016;',
			'icon-plus' : '&#xe017;',
			'icon-pencil' : '&#xe018;',
			'icon-note' : '&#xe019;',
			'icon-log-out' : '&#xe01a;',
			'icon-facebook-logo' : '&#xe01b;',
			'icon-facebook-btn' : '&#xe01c;',
			'icon-cross' : '&#xe01d;',
			'icon-cog' : '&#xe01e;',
			'icon-clock' : '&#xe01f;',
			'icon-checkmark' : '&#xe020;',
			'icon-arr-right' : '&#xe021;',
			'icon-arr-right-long' : '&#xe022;',
			'icon-arr-left' : '&#xe023;',
			'icon-arr-left-long' : '&#xe024;'
		},
		els = document.getElementsByTagName('*'),
		i, attr, c, el;
	for (i = 0; ; i += 1) {
		el = els[i];
		if(!el) {
			break;
		}
		attr = el.getAttribute('data-icon');
		if (attr) {
			addIcon(el, attr);
		}
		c = el.className;
		c = c.match(/icon-[^\s'"]+/);
		if (c && icons[c[0]]) {
			addIcon(el, icons[c[0]]);
		}
	}
};