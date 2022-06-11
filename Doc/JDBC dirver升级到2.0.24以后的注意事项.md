# JDBC dirver升级到2.0.24以后的注意事项

在2.0.24以后，在JDBC driver返回的结果集发生了变化，通过getObject方法，获取TIMSTAMP类型的数据时，返回值为java.sql.Timestamp类型，在2.0.24之前的版本，返回值为java.lang.Long类型；通过getObject方法，获取BINARY类型的数据时，返回值为byte[]类型，在2.0.24之前的版本，返回值为java.lang.String类型。

变化的原因，是为了将getObject的返回值类型与大多数满足JDBC标准的数据库行为保持一致，比如mysql。

下面类型的前后变化对照：

| TYPE      | JDBCType before 2.0.24(exclude) | JDBCType after 2.0.24(include) |
| --------- | ------------------------------- | ------------------------------ |
| TIMESTAMP | java.lang.Long                  | java.sql.Timestamp             |
| INT       | java.lang.Integer               | java.lang.Integer              |
| BIGINT    | java.lang.Long                  | java.lang.Long                 |
| FLOAT     | java.lang.Float                 | java.lang.Float                |
| DOUBLE    | java.lang.Duble                 | java.lang.Double               |
| SMALLINT  | java.lang.Short                 | java.lang.Short                |
| TINYINT   | java.lang.Byte                  | java.lang.Byte                 |
| BOOL      | java.lang.Boolean               | java.lang.Boolean              |
| BINARY    | java.lang.String                | [B                             |
| NCHAR     | java.lang.String                | java.lang.String               |



结果集类型的变动，造成了应用程序的代码有可能需要做出修改。如果希望使用2.0.34的driver，这里，我们提供一些修改的参考。

1. 原生JDBC代码，可以通过getLong来获取TIMSTAMP类型数据的毫秒数。

```java
long ts = rs.getLong("ts");
```

2. mybatis中可以使用TypeHandler来转换resultMap类型的结果

3. mybatis+springboot，可以通过spring的AOP，转换Map<String, Object>类型的结果集

```java
@Aspect
@Component
public class TaosAspect {

    @Around("execution(java.util.Map<String,Object> com.taosdata.example.springbootdemo.dao.*.*(..))")
    public Object handleType(ProceedingJoinPoint joinPoint) {
        Map<String, Object> result = null;
        try {
            result = (Map<String, Object>) joinPoint.proceed();
            for (String key : result.keySet()) {
                Object obj = result.get(key);
                if (obj instanceof byte[]) {
                    obj = new String((byte[]) obj);
                    result.put(key, obj);
                }
                if (obj instanceof Timestamp) {
                    obj = ((Timestamp) obj).getTime();
                    result.put(key, obj);
                }
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }
        return result;
    }
}


```

