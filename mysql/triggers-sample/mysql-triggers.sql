# INSERT
#   -- before: Check uniqueness
#   -- after: 
# UPDATE
#   -- before: Log old data
#   -- after: Email admin queue
# DELETE
#   -- before: check for dues
#   -- after: System cleanup

# http://dev.mysql.com/doc/refman/5.0/en/trigger-syntax.html
# http://net.tutsplus.com/tutorials/databases/introduction-to-mysql-triggers/
# http://www.cs.jhu.edu/~yarowsky/600.415.stored-procedures/mysql-triggers.pdf
# http://www.sitepoint.com/how-to-create-mysql-triggers/

DELIMITER ;

DROP TABLE IF EXISTS user_profiles;
CREATE TABLE `user_profiles` (
  `user_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'User ID',
  `user_name` VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'User Name',
  `user_email` VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'User Email',
  `user_password` VARCHAR(255) NOT NULL DEFAULT '' COMMENT 'User Password',
  PRIMARY KEY (`user_id`)
);

DROP TABLE IF EXISTS user_profiles_modified;
CREATE TABLE user_profiles_modified LIKE user_profiles;

ALTER TABLE `user_profiles_modified`
ADD COLUMN `created_on` DATETIME DEFAULT '0000-00-00 00:00:00' NOT NULL COMMENT 'Modified On' AFTER `user_id`,
ADD COLUMN `modified_on` DATETIME DEFAULT '0000-00-00 00:00:00' NOT NULL COMMENT 'Modified On' AFTER `created_on`,
ADD COLUMN `deleted_on` DATETIME DEFAULT '0000-00-00 00:00:00' NOT NULL COMMENT 'Deleted On' AFTER `modified_on`;

ALTER TABLE `user_profiles_modified` CHANGE `user_id` `user_id` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'User ID', DROP PRIMARY KEY;
ALTER TABLE `user_profiles_modified` ADD COLUMN `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Runner ID' FIRST, ADD PRIMARY KEY(`id`);

DROP TRIGGER IF EXISTS before_user_profiles_modified;
DELIMITER $$
CREATE TRIGGER before_user_profiles_modified
BEFORE UPDATE ON `user_profiles`
FOR EACH ROW BEGIN
	INSERT INTO user_profiles_modified (
		modified_on, user_id, user_name, user_email
	) VALUES(
		NOW(), OLD.user_id, OLD.user_name, OLD.user_email
	);
END $$

DELIMITER ;
DROP TRIGGER IF EXISTS after_user_profiles_modified;
DELIMITER $$
CREATE TRIGGER after_user_profiles_modified
AFTER UPDATE ON `user_profiles`
FOR EACH ROW BEGIN
	INSERT INTO user_profiles_modified (
		modified_on, user_id, user_name, user_email
	) VALUES(
		NOW(), NEW.user_id, NEW.user_name, NEW.user_email
	);
END $$