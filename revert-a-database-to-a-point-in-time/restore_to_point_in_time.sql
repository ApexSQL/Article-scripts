-- Restore full database backup
RESTORE DATABASE AdventureWorks2012
   FROM AW2012Backups
   WITH FILE=2, NORECOVERY;

-- Restore transaction log backup which is a part of the full chain
RESTORE LOG AdventureWorks2012
   FROM AW2012Backups
   WITH FILE=3, NORECOVERY, STOPAT = 'June 3, 2013 6:00 PM';

-- Restore transaction log backup which contains a point in time 
RESTORE LOG AdventureWorks2012
   FROM AW2012Backups
   WITH FILE=4, NORECOVERY, STOPAT = 'June 6, 2013 6:00 PM';
RESTORE DATABASE AdventureWorks2012 WITH RECOVERY; 
GO