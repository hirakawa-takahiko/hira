#!/bin/bash
DB=aff
MYSQL="mysql -u mysql -pEiV3X8q1 --database=$DB --batch --skip-column-names  "
echo $MYSQL

for TBL in `${MYSQL} -e 'SHOW TABLES' ` 
do
	echo "--$TBL---"
	$MYSQL -e "ALTER TABLE $TBL DEFAULT CHARSET=utf8mb4"
done
