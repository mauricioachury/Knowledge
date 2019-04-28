# MAD Graphs

MAD Graphs is a Java tool that lets you generate graphs of MAD probe data. The current supported formats are MAD 2.0+ generated with a MOCA support zip.

# Building
This tool is built with Maven. It currently requires Java 7 to build and run.

    mvn package
    
# GUI Usage
Use the following to produce a GUI with charts of probe data from a support zip file. Alternatively, you can double click the JAR file to run the tool.

    java -jar target/mad-graphs.jar
    
# Command Line Usage
Use the following to produce individual chart windows of probe data. Use available flags to select subsets of data to graph. For example, use **-o** to graph a JVM overview.
 
    usage: java -cp mad-graphs.jar com.jda.mad.GraphAllProbesFromSupportZip <support-zip> [options]
     -o,--jvm-overview      Graph JVM and OS overview
     -m,--moca-overview     Graph MOCA overview
     -w,--ws                Graph all web services (dynamic)
     -j,--jobs              Graph all jobs (dynamic)
     -t,--tasks             Graph all tasks (dynamic)
     -i,--integrator        Graph all integrator probes (dynamic)
     -d,--wm                Graph all WM probes
     -e,--everything-else   Graph all other probes (not captured by other
                            categories)
     -h,--help              Print usage
    Note that dynamic items may produce a large number of graphs. The actual
    number of graphs will depend on products installed, customizations, etc.
    
