 UNIX���ļ���̫�������
���ļ�̫����ʾ��ԭ��
 
һ��ʲô����£����½��ʹ��ļ���
1��A JVM opens many files in order to read in the classes required to run your application.
High volume applications can use a lot of files in many ways.
2��each new socket requires a file. Clients and Servers communicate via TCP sockets.
3��Each browser's http request consumes TCP sockets when a connection is established to a Server.


�����ļ����������ͷţ����ļ������������޷���������ʾ�ľ��������ʹ��������ʶ�򿪵��ļ���
1�����ļ��رջ������ֹʱ���رյġ�
2�����������ĳ���ļ�������������ر���֮�����������ļ��������������̺��ӽ��̣��ļ����������Լ̳У������ӽ���ʹ�ã���
3��TIME_WAIT ����ʱ���Ż��ͷ� TCP �׽����ļ���������
���� Unixϵͳ��, TIME_WAIT��kernel����tcp_time_wait_interval������.��Windows��,������������� HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters�� TcpTimedWaitDelay��ֵ
��.  Ĭ��ֵ��240�� (tcp_time_wait _interval �� TcpTimedWaitDelay)��
4�������ļ�ʱ�������ùرյ��ļ�������

�����鿴�ļ��������ķ�����
1����UNIXƽ̨��ʹ�á��ļ��б� (lsof) ������ʾ�йش򿪵��ļ��������ļ�����������Ϣ��
   ����ض���process ,�����ǣ� lsof -p <pid of process>
   �������������쳣����������ļ������������Ҳ����ͨ��lsof �Ch ��ʾ��Ӧ���﷨��ѡ�
   �˳������°汾��ͨ��������ַ��ã�   http://ftp.cerias.purdue.edu/pub/tools/unix/sysutils/lsof/
2, ��WINDOWSƽ̨��ʹ��handle ���߱����йش��ļ��������Ϣ��
   �Ƽ�ʹ��Process Explorer ���߲鿴���еĽ��̺ʹ򿪵��ļ��б�.(google��һ��)

�ģ� ���֮����

1�����������쳣�Ľ��̣��붨��ͨ�����߻�������ý��̴򿪵��ļ���/�����ӡ�
2��������������ϵͳ�Խ��̺�������ļ����������ƽ��бȽϡ�
3�����ݼ������ʵ����Ҫ��� OS �������ֲ��ļ����������㡣��ʹTIME_WAIT �ڼ�����Ϊһ���к� ʵ�ʵ�ֵ��

  ע�����
  1�����δ��ȷ�ر��ļ����ļ�����������δ���ͷš�
  2������ӽ���ʹ�õ�������δ�ر��ļ������������ø��ļ������������̳и������ļ���������
  3, TIME_WAIT ����ǰ��TCP �׽��ֻ�ʹ�ļ����������ִ�״̬��
  4, �벻Ҫ���� GC �Ͷ�������������ͷ��ļ�������

�壬 ����޸��ļ���������

����ϵͳ��Դ���ƿ��ƣ�
����ʹ�õ��ļ�����������
�������������Դ򿪵�����������
���磺
1��Windows: ͨ���ļ����,���ļ��������Ϊ 16,384.

2��Solaris: rlim_fd_cur �� rlim_fd_max
    /usr/bin/ulimit ʵ�ó���������������ʹ�õ��ļ��������������� �������ֵ�� rlim_fd_max �ж��壬��ȱʡ����£�������Ϊ 65,536�� ֻ��ROOT�û������޸���Щ�ں�ֵ��

3��HPUX: nfile, maxfiles �� maxfiles_lim
  nfile ������ļ������������ ��ֵͨ�������¹�ʽ��ȷ���� ((NPROC*2)+1000)������ NPROC ͨ��Ϊ�� ((MAXUSERS*5)+64)��  ��� MAXUSERS ���� 400���򾭹�����õ���ֵΪ 5128�� ͨ�����Խ���ֵ���һЩ��maxfiles ��ÿ�����̵����ļ����ޣ�maxfiles_lim ��ÿ�����̵�Ӳ�ļ����ޡ�

4��Linux: nofile �� file-max
    �����û������� etc/security/limits.conf �����ļ����������ǵ��ļ����������ޣ���������ʾ��
    soft nofile 1024
    hard nofile 4096
    �����������£�
    echo 4096 > /proc/sys/fs/file-max
    echo 16384 > /proc/sys/fs/inode-max

5,AIX: OPEN_MAX
    �ļ������������� /etc/security/limits �ļ������ã�����ȱʡֵ�� 2000�� �˼��޿���ͨ�� ulimit ����� setrlimit �����������ġ� ����С�� OPEN_MAX ���������塣


 
�鿴�����ļ���
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
 
�鿴ĳһ������(JAVA)�򿪵��ļ���:
[root@localhost ~]# ps -ef | grep java
root      2992     1  0 09:49 ?        00:00:13 /u01/j2sdk1.4.2_09/bin/java -client -Xms512m -Xmx2048m -XX:MaxPermSize=128m -Xverify:none -Dweblogic.Name=myserver -Dweblogic.ProductionModeEnabled= -Djava.awt.headless=true -Djava.security.policy=/u01/bea/weblogic81/server/lib/weblogic.policy weblogic.Server
root      4589  4556  0 13:55 pts/1    00:00:00 grep java
 
[root@localhost ~]# lsof -p 2992|wc -l
467
 
���������ļ���:
 
����/etc/security/limits.conf�ļ�����:
 
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
