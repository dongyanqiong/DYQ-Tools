// 超级表名称 STBNAME
// 标签 TAG
// 列名 COL_NAME
// 时间窗口 TWA
// 过滤 FILTER


//聚合查询  count,avg,max,min,spread,sum
select FUN_NAME(COL_NAME) from STBNAME FILTER ;

select FUN_NAME(COL_NAME),tbname from STBNAME FILTER group by tbname;

select FUN_NAME(COL_NAME),TAG from STBNAME FILTER group by TAG;

select FUN_NAME(COL_NAME),TAG from STBNAME FILTER group by TAG ;

select _wstart as ts, FUN_NAME(COL_NAME) from STBNAME FILTER interval(TWA);

select _wstart as ts, FUN_NAME(COL_NAME) from STBNAME FILTER interval(TWA) order by ts asc;

select _wstart as ts, FUN_NAME(COL_NAME) from STBNAME FILTER interval(TWA) order by ts desc;

select _wstart as ts, FUN_NAME(COL_NAME),TAG from STBNAME FILTER interval(TWA) partition by TAG;

select _wstart as ts, FUN_NAME(COL_NAME),TAG from STBNAME FILTER interval(TWA) partition by TAG order by ts asc/desc ;

select _wstart as ts, FUN_NAME(COL_NAME),TAG from STBNAME FILTER interval(TWA) partition by TAG order by ts asc/desc,TAG ;

