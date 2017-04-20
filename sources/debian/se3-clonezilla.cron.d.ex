#
# Regular cron jobs for the sambaedu-clonezilla package
#
0 4	* * *	root	[ -x /usr/bin/sambaedu-clonezilla_maintenance ] && /usr/bin/sambaedu-clonezilla_maintenance
