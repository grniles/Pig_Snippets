batters = LOAD 'hdfs:/user/maria_dev/pigtest/Batting.csv' USING PigStorage(',');
master = LOAD 'hdfs:/user/maria_dev/pigtest/Master.csv' USING PigStorage(',');
realBatters = FILTER batters BY $1 > 0;
batterData = FOREACH realBatters GENERATE $0 AS id, $1 AS year, $8 AS doubles, $9 AS triples, $10 AS hr;
masterData = FOREACH master GENERATE $0 AS id, $15 AS playerName;
totallyEighties = FILTER batterData BY year >= 1980 AND year <= 1989;
totalExtra = FOREACH totallyEighties GENERATE id, (doubles + triples + hr) AS extra;
groupExtra = GROUP totalExtra BY id;
countTotal = FOREACH groupExtra GENERATE group, SUM(totalExtra.extra) AS sumExtra;
groupCount = GROUP countTotal ALL;
maxExtra = FOREACH groupCount GENERATE MAX(countTotal.sumExtra) as maxTotal;
joinExtra = JOIN maxExtra BY maxTotal, countTotal BY sumExtra;
joinMaster = JOIN joinExtra BY countTotal::group, masterData BY id;
most = FOREACH joinMaster GENERATE playerName;
DUMP most;