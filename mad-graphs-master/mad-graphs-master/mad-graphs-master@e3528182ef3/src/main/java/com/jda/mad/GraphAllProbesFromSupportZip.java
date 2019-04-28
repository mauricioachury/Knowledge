package com.jda.mad;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.TimeZone;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import com.jda.mad.graphs.ChartType;
import com.jda.mad.graphs.Grapher;
import com.jda.mad.graphs.Utils;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

/**
 * Application to create graphs from MOCA support zip files. This application works solely on command line arguments
 * to be able to filter down the number of graphs. Each graph is opened in a new window.
 * <p/>
 * Copyright (c) 2016 JDA Software All Rights Reserved
 *
 * @author mdobrinin
 */
public class GraphAllProbesFromSupportZip {

    public static void main(String[] args) throws IOException, ParseException {
        final CommandLine options = getOptions(args);
        String supportZip = "";
        try {
            supportZip = getSupportZipArg(options);
        }
        catch (IllegalStateException e) {
            printUsage();
            System.exit(0);
        }

        final ZipFile zipFile = new ZipFile(supportZip);
        final Enumeration<? extends ZipEntry> entries = zipFile.entries();

        // figure out the timezone from the support zip so that we can display dates
        // in the same way as they appear on the instance -- this is needed to make them match the logs
        String timeZone = Utils.determineTimeZone(zipFile);
        if (timeZone != null) {
            System.out.println("Setting time zone... " + timeZone);
            Grapher.setTimeZone(timeZone);
        }
        else {
            System.out.println("Defaulting to time zone... " + TimeZone.getDefault());
            Grapher.setTimeZone(TimeZone.getDefault().getDisplayName());
        }

        while(entries.hasMoreElements()) {
            final ZipEntry entry = entries.nextElement();
            final String name = entry.getName();

            String separatorRegex = "/";
            if (name.startsWith("csv_probe_data")) {
                final String separator;
                if (name.contains("/")) {
                    separator = "/";
                }
                else if (name.contains("\\")) {
                    separator = "\\";
                    separatorRegex = "\\\\";
                }
                else {
                    throw new RuntimeException("Unknown separator in entry {" + name + "}");
                }

                final String pkg = name.substring(name.indexOf(separator) + 1);
                final String[] strings = pkg.split(separatorRegex);
                final List<ChartType> chartTypes = findChartTypes(options);

                // only graph this probe if it was requested
                if (Utils.filter(strings[0], strings[1], chartTypes)) {
                    final List<String> data = Utils.readEntry(zipFile, entry);
                    if (data.size() >= 2) {
                        Grapher.chartSingleFile(strings[0], strings[1], data);
                    }
                }
            }
        }
    }
    
    private static List<ChartType> findChartTypes(CommandLine options) {
        List<ChartType> chartTypes = new ArrayList<ChartType>();
        if (options.hasOption('o')) chartTypes.add(ChartType.JVM);
        if (options.hasOption('m')) chartTypes.add(ChartType.MOCA);
        if (options.hasOption('w')) chartTypes.add(ChartType.WS);
        if (options.hasOption('j')) chartTypes.add(ChartType.JOBS);
        if (options.hasOption('t')) chartTypes.add(ChartType.TASKS);
        if (options.hasOption('i')) chartTypes.add(ChartType.INTEGRATOR);
        if (options.hasOption('d')) chartTypes.add(ChartType.WM);
        if (options.hasOption('e')) chartTypes.add(ChartType.OTHER);
        return chartTypes;
    }

    /**
     * Parse the options from
     * @param args
     * @return
     * @throws ParseException
     */
    static CommandLine getOptions(String[] args) throws ParseException {
        Options options = defaultOptions();

        CommandLineParser parser = new DefaultParser();
        try {
            CommandLine cmd = parser.parse(options, args);
            if (cmd.hasOption("h") || cmd.getOptions().length == 0) {
                printUsage();
                System.exit(0);
            }
            return cmd;
        }
        catch (Exception e) {
            printUsage();
            System.exit(0);
        }
        return null;
    }

    /**
     * Get the actual support zip file path from the arguments.
     * @param c command line options
     * @return support zip arg
     */
    static String getSupportZipArg(CommandLine c) {
        List<String> argList = c.getArgList();
        if (argList.size() != 1 || argList.get(0).isEmpty())  {
            throw new IllegalStateException("Invalid arguments");
        }

        return argList.get(0);
    }

    private static Options defaultOptions() {
        Options options = new Options();
        options.addOption("o", "jvm-overview", false, "Graph JVM and OS overview");
        options.addOption("m", "moca-overview ", false, "Graph MOCA overview");
        options.addOption("w", "ws", false, "Graph all web services (dynamic)");
        options.addOption("j", "jobs", false, "Graph all jobs (dynamic)");
        options.addOption("t", "tasks", false, "Graph all tasks (dynamic)");
        options.addOption("i", "integrator", false, "Graph all integrator probes (dynamic)");
        options.addOption("d", "wm", false, "Graph all WM probes");
        options.addOption("e", "everything-else", false, "Graph all other probes (not captured by other categories)");
        options.addOption("h", "help", false, "Print usage");
        return options;
    }

    private static void printUsage() {
        HelpFormatter formatter = new HelpFormatter();
        // set comparator as null to preserve declaration order
        formatter.setOptionComparator(null);
        formatter.printHelp( "java -jar mad-graphs.jar <support-zip> [options]", null, defaultOptions(), "Note that dynamic items may produce a large number of graphs. The actual number of graphs will depend on products installed, customizations, etc.");
    }
}