---
title: MySQL相关总结
date: 2020-07-14 11:52:37
type: MySQL
tags: MySQL
---

# MySQL 数据库

MySQL 是最流行的关系型数据库管理系统，在 WEB 应用方面 MySQL 是最好的 RDBMS(Relational Database Management System：关系数据库管理系统)应用软件之一。

<!--more-->

# MySQL存储引擎

## 查看当前存储引擎

```sql
show variables like '%storage_engine';
show engines;
```

## MySQL常用引擎

1. InnoDB

   事务型数据库的首选引擎，支持事务安全表（ACID），支持行锁定和外键，InnoDB是默认的MySQL引擎。

   InnoDB主要特性有：

   1. InnoDB 给 MySQL 提供了具有提交、回滚、崩溃恢复能力的事务安全存储引擎。
   2. InnoDB 是为处理巨大数据量的最大性能设计。它的 CPU 效率比其他基于磁盘的关系型数据库引擎高。
   3. InnoDB 存储引擎自带缓冲池，可以将数据和索引缓存在内存中。
   4. InnoDB 支持外键完整性约束。
   5. InnoDB 被用在众多需要高性能的大型数据库站点上
   6. InnoDB 支持行级锁

2. MyISAM

   MyISAM 基于 ISAM 存储引擎，并对其进行扩展。它是在Web、数据仓储和其他应用环境下最常使用的存储引擎之一。MyISAM 拥有较高的插入、查询速度，但不支持事物。

   MyISAM主要特性有：

   1. 大文件支持更好
   2. 当删除、更新、插入混用时，产生更少碎片。
   3. 每个 MyISAM 表最大索引数是64，这可以通过重新编译来改变。每个索引最大的列数是16
   4. 最大的键长度是1000字节。
   5. BLOB和TEXT列可以被索引
   6. NULL 被允许在索引的列中，这个值占每个键的0~1个字节
   7. 所有数字键值以高字节优先被存储以允许一个更高的索引压缩
   8. MyISAM 类型表的 AUTO_INCREMENT 列更新比 InnoDB 类型的 AUTO_INCREMENT 更快
   9. 可以把数据文件和索引文件放在不同目录
   10. 每个字符列可以有不同的字符集
   11. 有 VARCHAR 的表可以固定或动态记录长度
   12. VARCHAR 和 CHAR 列可以多达 64KB
   13. 只支持表锁

3. MEMORY

   MEMORY 存储引擎将表中的数据存储到内存中，为查询和引用其他表数据提供快速访问。

## 存储引擎的选择

一般来说，对插入和并发性能要求较高的，或者需要外键，或者需要事务支持的情况下，需要选择 InnoDB，

插入较少，查询较多的场景，优先考虑 MyISAM。

### 使用引擎

一般在建表时添加

```
create table abc (
    name char(10)
) engine=MyISAM charset=utf8;

create table xyz (
    name char(10)
) engine=InnoDB charset=utf8;
```

### InnoDB 和 MyISAM 在文件方面的区别

1. InnoDB 将一张表存储为两个文件

   - demo.frm -> 存储表的结构和索引
   - demo.ibd -> 存储数据，ibd 存储是有限的, 存储不足自动创建 ibd1, ibd2
   - InnoDB 的文件创建在对应的数据库中, 不能任意的移动

2. MyISAM 将一张表存储为三个文件

   - demo.frm -> 存储表的结构

   - demo.myd -> 存储数据

   - demo.myi -> 存储表的索引

   - MyISAM 的文件可以任意的移动

     

# MySQL索引

## 索引介绍

### 索引是什么

- 索引是帮助MySQL**高效获取数据的数据结构**，能**加快数据库检索速度**、**排序**等，类似于一本书的目录。

- 索引本身往往是存储在磁盘上的文件中的（单独的索引文件或者是和数据库一起存储在数据文件中（InnoDB））
- 包括**聚集索引、覆盖索引、组合索引、前缀索引、唯一索引等**，一般默认使用的都是**B+树结构**的索引

### 索引的优势和劣势

**优势：**

- 可以**提高数据检索的效率**，降低数据库的IO成本；
- 可以通过索引**对数据进行排序**，降低数据排序的成本，减少CPU消耗；
  - 被索引的列会自动排序，包括**单列索引**和**组合索引**；
  - 按照索引列的顺序进行order by **排序效率会提高**很多；
  - where 索引列 在存储引擎层处理；

**劣势：**

- 会**占用内存空间**；
- 虽然会提高搜索效率，但是会**降低更新表的效率**，因为每次修改不光要修改表数据，还要修改对应的索引文件；

## 索引的分类

### 单列索引

- 普通索引：MySQL中最基本的索引，没有什么限制，允许在定义索引的列中插入重复值的空值，纯粹是为了查询更快；(**add index**)
- 唯一索引：索引中的值必须是唯一的，但是允许为空值；(**add unique index**)
- 主键索引：特殊的唯一索引，不允许为空值。pk

### 组合索引

- 多个字段组合上创建的索引；(**add index(col1, col2,...)**)
- 需要遵循**最左前缀原则（最左匹配原则）**
- 一般**建议使用组合索引代替单列索引（主键除外）**

### 全文索引

只有在MyISAM、InnoDB（5.6以后）上才能使用，而且只能在CHAR、VARCHAR、TEXT类型字段上使用全文索引。

优先级最高，最先执行，不会执行其他索引

### 空间索引



## 索引的使用

### 创建索引

- 单列索引——普通索引

  ```python
  CREATE INDEX index_name ON table_name (column_name);
  ALTER TABLE table_name ADD INDEX index_name (column_name);
  ```

- 单列索引——唯一索引

  ```python
  CREATE UNIQUE INDEX index_name ON table_name (column_name);
  ALTER TABLE table_name ADD UNIQUE INDEX index_name(column_name);
  ```

- 单列索引——全文索引

  ```python
  CREATE UNIQUE FULLTEXT INDEX fulltext_index_name ON table_name (column_name)
  ```

- 组合索引

  ```python
  CREATE INDEX index_name ON table_name (column_name_1, column_name_2);
  ```

  

### 删除索引

```python
DROP INDEX index_name ON table_name;
```

### 查看索引

```python 
SHOW INDEX FROM table_name;
```



## 索引原理分析

### 索引的存储结构

- 索引是在**存储引擎中实现**的，也就是说使用不同的存储引擎，会使用不同的索引；
- **MyISAM** 和 **InnoDB** 存储引擎：**只支持 B+TREE 索引**，**默认使用BTREE**，不能更换；
- MEMORY/HEAP 存储引擎：支持HASH和BTREE索引；
  (HASH索引比BTREE快，所以MEMORY引擎也更快)

### B树 和 B+树

数据结构演示网址：https://www.cs.usfca.edu/~galles/visualization/Algorithms.html

#### B树

- 定义：

  

#### B+树

- 定义：

  

# MySQL 事务

## 一、事务

- 事务主要处理操作量大、复杂度高、并且关联性强的数据。

- 进行一系列相互关联的操作：删除用户—>删除该用户相关所有的表数据。

- 在MySQL中只有InnoDB存储引擎支持事务。
- 事务处理可以用来维护数据库的数据完整性，保证成批的SQL语句要么不执行，要么都执行成功。

## 二、事物的四大特性

在写入或更新数据的过程中，为保证事务的正确可靠，必需具备四个特性（ACID）：

1. **原子性**（Atomicity）

   - 事务中的所有操作，要么全部完成，要么全部不执行，不会结束在中间某个环节；
   - 事务在执行过程中发生错误，会被**回滚（Rollback）**到事务开始时前的状态，执行完成会有提交操作；

2. **一致性**（Consistency）

   ​		事务开始前和事务结束后，数据库的完整性不能被破坏，写入的数据完全符合数据库的预设规则，这包含资料的精确度、串联性以及后续数据库可以自发性地完成预定的工作。

3. **隔离性**（Isolation）

   ​		事务并发会相互影响，多个事务同时操作同一个数据时可能会出现的问题：

   - **脏读**：事务A修改了一个数据，但未提交，**事务B读到了事务A未提交的更新结果**，如果事务A提交失败，事务B读到的就是脏数据。
   - **不可重复读**：在同一个事务中，对于同一个数据读取的结果不一致。比如，**事务B在事务A提交前后读取到的内容不一致**，导致的原因就是并发修改记录。想要避免这种情况，就要**对修改的记录进行加锁**，但这会导致锁竞争加剧，影响性能。另一种方式是通过**MVCC（多版本的并发控制）**可以在无锁的情况下避免不可重复读。
   - **幻读**：在同一个事务中，同一个查询多次返回的结果不一致。事务A新增了一条记录，事务B在事务A提交前后各执行了一次查询操作，发现后一次比前一次多了一条记录。幻读是由于并发事务增加记录导致的，这个不能像不可重复读通过记录加锁解决，因为对于新增的记录根本无法加锁。需要将事务串行化，才能避免幻读。

   事务的隔离级别从低到高：

   1. **读取未提交 (Read uncommitted)**
      - 所有事物都可以看到其他未提交事务的执行结果
      - 性能不好
      - 会引发**脏读**：读取到未提交的数据
   2. **读提交 (read committed)**
      - 大多数数据库的默认隔离级别（MySQL除外）
      - 满足了隔离：只能看见已提交事务的改变
      - 会引发**不可重复读**：事务执行过程中数据可能会被其他事务修改并提交
   3. **可重复读 (repeatable read)**
      - **MySQL的默认隔离级别**
      - 同一事务的多个实例在并发读取数据时，会看到同样的数据行
      - 会引发**幻读**：多事务同时操作会导致多次读取不一致
      - InnoDB 通过多版本并发控制 (MVCC，Multiversion Concurrency Control) 机制解决幻读问题；
      - InnoDB 还通过间隙锁解决幻读问题
   4. **串行化 (Serializable)**
      - 这是最高的隔离级别
      - 它通过强制事务排序，使之不可能相互冲突，从而解决幻读问题。简言之,它是在每个读的数据行上加上共享锁。MySQL锁总结
      - 在这个级别，可能导致大量的超时现象和锁竞争

4. **持久性**（Durability）

   事务处理结束后, 对数据的修改就是永久的, 即便系统故障也不会丢失。

## 三、语法和使用

- 开启事务: `BEGIN`或`START TRANSACTION`

- 提交事务: `COMMIT`, 提交会让所有修改生效

- 回滚: `ROLLBACK`, 撤销正在进行的所有未提交的修改

- 创建保存点: `SAVEPOINT identifier`

- 删除保存点: `RELEASE SAVEPOINT identifier`

- 把事务回滚到保存点: `ROLLBACK TO identifier`

- 查询事务的隔离级别: `show variables like '%isolation%';`

- 设置事务的隔离级别: `SET [SESSION | GLOBAL] TRANSACTION ISOLATION LEVEL {READ UNCOMMITTED | READ COMMITTED | REPEATABLE READ | SERIALIZABLE}`

  InnoDB 提供的隔离级别有

  - `READ UNCOMMITTED`

  - `READ COMMITTED`

  - `REPEATABLE READ`

  - `SERIALIZABLE`

    

### 示例：

```sql
create table `abc` (
    id int unsigned primary key auto_increment,
    name varchar(32) unique,
    age int unsigned
) charset=utf8;

begin;
insert into abc (name, age) values ('aa', 11);
insert into abc (name, age) values ('bb', 22);
-- 在事务中查看一下数据
-- 同时另开一个窗口，连接到 MySQL 查看一下数据是否一样
select * from abc;
commit;

begin;
insert into abc (name, age) values ('cc', 33);
insert into abc (name, age) values ('dd', 44);
update abc set age=77 where name='aa';
-- 在事务中查看一下数据
select * from abc;
rollback;

select * from abc;  -- 事务结束后在查看一下数据
```
