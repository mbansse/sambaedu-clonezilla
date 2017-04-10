#
# Regular cron jobs for the se3-clonezilla package
#
0 4	* * *	root	[ -x /usr/bin/se3-clonezilla_maintenance ] && /usr/bin/se3-clonezilla_maintenance
