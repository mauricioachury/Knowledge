 UNIX下文件打开太多的问题
打开文件太多提示的原因
 
一，什么情况下，会新建和打开文件：
1，A JVM opens many files in order to read in the classes required to run your application.
High volume applications can use a lot of files in many ways.
2，each new socket requires a file. Clients and Servers communicate via TCP sockets.
3，Each browser's http request consumes TCP sockets when a connection is established to a Server.


二，文件描述符的释放：（文件描述符是由无符号整数表示的句柄。进程使用它来标识打开的文件）
1，在文件关闭或进程终止时被关闭的。
2，如果想重用某个文件描述符，必须关闭与之关联的所有文件描述符（父进程和子进程：文件描述符可以继承，可由子进程使用）。
3，TIME_WAIT 结束时，才会释放 TCP 套接字文件描述符。
（在 Unix系统中, TIME_WAIT在kernel参数tcp_time_wait_interval中设置.在Windows中,这个参数定义在 HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters的 TcpTimedWaitDelay键值
中.  默认值是240秒 (tcp_time_wait _interval 和 TcpTimedWaitDelay)）
4，打开新文件时将会重用关闭的文件描述符

三，查看文件描述符的方法：
1，在UNIX平台，使用“文件列表” (lsof) 工具显示有关打开的文件和网络文件描述符的信息。
   针对特定的process ,语句就是： lsof -p <pid of process>
   这个命令可以在异常发生后检查打开文件的最大数，你也可以通过lsof –h 显示相应的语法和选项。
   此程序最新版本可通过以下网址获得：   http://ftp.cerias.purdue.edu/pub/tools/unix/sysutils/lsof/
2, 在WINDOWS平台，使用handle 工具报告有关打开文件句柄的信息。
   推荐使用Process Explorer 工具查看运行的进程和打开的文件列表.(google查一下)

四， 解决之道：

1，对于引发异常的进程，请定期通过工具或命令检查该进程打开的文件和/或连接。
2，将检查结果与操作系统对进程和总体的文件描述符限制进行比较。
3，根据检查结果和实际需要提高 OS 限制来弥补文件描述符不足。并使TIME_WAIT 期间缩短为一个切合 实际的值。

  注意事项：
  1，如果未正确关闭文件，文件描述符可能未被释放。
  2，如果子进程使用的描述符未关闭文件，将不能重用该文件描述符。（继承父进程文件描述符）
  3, TIME_WAIT 结束前，TCP 套接字会使文件描述符保持打开状态。
  4, 请不要依赖 GC 和对象清除功能来释放文件描述符

五， 如何修改文件描述符：

操作系统资源限制控制：
可以使用的文件描述符总数
单个进程最多可以打开的描述符数。
例如：
1，Windows: 通过文件句柄,打开文件句柄设置为 16,384.

2，Solaris: rlim_fd_cur 和 rlim_fd_max
    /usr/bin/ulimit 实用程序定义允许单个进程使用的文件描述符的数量。 它的最大值在 rlim_fd_max 中定义，在缺省情况下，它设置为 65,536。 只有ROOT用户才能修改这些内核值。

3，HPUX: nfile, maxfiles 和 maxfiles_lim
  nfile 定义打开文件的最大数量。 此值通常由以下公式来确定： ((NPROC*2)+1000)，其中 NPROC 通常为： ((MAXUSERS*5)+64)。  如果 MAXUSERS 等于 400，则经过计算得到此值为 5128。 通常可以将此值设高一些。maxfiles 是每个进程的软文件极限，maxfiles_lim 是每个进程的硬文件极限。

4，Linux: nofile 和 file-max
    管理用户可以在 etc/security/limits.conf 配置文件中设置他们的文件描述符极限，如下例所示。
    soft nofile 1024
    hard nofile 4096
    设置命令如下：
    echo 4096 > /proc/sys/fs/file-max
    echo 16384 > /proc/sys/fs/inode-max

5,AIX: OPEN_MAX
    文件描述符极限在 /etc/security/limits 文件中设置，它的缺省值是 2000。 此极限可以通过 ulimit 命令或 setrlimit 子例程来更改。 最大大小由 OPEN_MAX 常数来定义。


 
查看最大打开文件数
[root@localhost ~]# ulimit -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
file size               (blocks, -f) unlimited
pending signals                 (-i) 1024
max locked memory       (kbytes, -l) 32
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
stack size              (kbytes, -s) 10240
cpu time               (seconds, -t) unlimited
max user processes              (-u) 81920
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited
 
查看某一个进程(JAVA)打开的文件数:
[root@localhost ~]# ps -ef | grep java
root      2992     1  0 09:49 ?        00:00:13 /u01/j2sdk1.4.2_09/bin/java -client -Xms512m -Xmx2048m -XX:MaxPermSize=128m -Xverify:none -Dweblogic.Name=myserver -Dweblogic.ProductionModeEnabled= -Djava.awt.headless=true -Djava.security.policy=/u01/bea/weblogic81/server/lib/weblogic.policy weblogic.Server
root      4589  4556  0 13:55 pts/1    00:00:00 grep java
 
[root@localhost ~]# lsof -p 2992|wc -l
467
 
更改最大打开文件数:
 
更改/etc/security/limits.conf文件配置:
 
# /etc/security/limits.conf
#
#Each line describes a limit for a user in the form:
#
#<domain>        <type>  <item>  <value>
#
#Where:
#<domain> can be:
#        - an user name
#        - a group name, with @group syntax
#        - the wildcard *, for default entry
#        - the wildcard %, can be also used with %group syntax,
#                 for maxlogin limit
#
#<type> can have the two values:
#        - "soft" for enforcing the soft limits
#        - "hard" for enforcing hard limits
#
#<item> can be one of the following:
#        - core - limits the core file size (KB)
#        - data - max data size (KB)
#        - fsize - maximum filesize (KB)
#        - memlock - max locked-in-memory address space (KB)
#        - nofile - max number of open files
#        - rss - max resident set size (KB)
#        - stack - max stack size (KB)
#        - cpu - max CPU time (MIN)
#        - nproc - max number of processes
#        - as - address space limit
#        - maxlogins - max number of logins for this user
#        - priority - the priority to run user process with
#        - locks - max number of file locks the user can hold
#
#<domain>      <type>  <item>         <value>
#
#*               soft    core            0
#*               hard    rss             10000
#@student        hard    nproc           20
#@faculty        soft    nproc           20
#@faculty        hard    nproc           50
#ftp             hard    nproc           0
#@student        -       maxlogins       4

# End of file
