package com.jda.mad.graphs;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

/**
 * Helper methods.
 * <p/>
 * Copyright (c) 2016 JDA Software All Rights Reserved
 *
 * @author mdobrinin
 */
public class Utils {

    /**
     * Read zip entry from file and return contents as list of lines.
     * @param zip
     * @param entry
     * @return
     * @throws IOException
     */
    public static List<String> readEntry(ZipFile zip, ZipEntry entry) throws IOException {
        final BufferedReader reader = new BufferedReader(new InputStreamReader(zip.getInputStream(entry)));
        final List<String> ret = new ArrayList<>();
        String line;
        while ((line = reader.readLine()) != null) {
            ret.add(line);
        }
        return ret;
    }

    /**
     * Figure out the timezone from the support zip.
     * @param zipFile support zip.
     * @return time zone or null
     */
    public static String determineTimeZone(ZipFile zipFile) throws IOException {
        final Enumeration<? extends ZipEntry> entries = zipFile.entries();
        while(entries.hasMoreElements()) {
            final ZipEntry entry = entries.nextElement();
            final String name = entry.getName();
            if (name.equals("system-properties.txt")) {
                final List<String> data = Utils.readEntry(zipFile, entry);
                for (String datum : data) {
                    if (datum.startsWith("user.timezone")) {
                        return datum.substring(datum.indexOf('=') + 1);
                    }
                }
            }
        }
        return null;
    }
    
    /**
     * Finds certain charts to graph depending on charts parameter
     * @param group probe group
     * @param metricName probe name (not exact since it's picked up from filename after being formatted)
     * @param charts list of ChartType
     * @return whether this chart should be graphed
     */
    public static boolean filter(String group, String metricName, List<ChartType> charts) {
        // MAD probes are all JVM and OS info
        if (group.equals("com.redprairie.mad")) return charts.contains(ChartType.JVM);

        // MOCA sub-areas
        if (group.equals("com.redprairie.moca") && metricName.startsWith("Tasks__")) return charts.contains(ChartType.TASKS);
        if (group.equals("com.redprairie.moca") && metricName.startsWith("Jobs__")) return charts.contains(ChartType.JOBS);
        if (group.equals("com.redprairie.moca") && metricName.startsWith("Web-Services__")) return charts.contains(ChartType.WS);

        // MOCA overview flag
        if (group.equals("com.redprairie.moca")) return charts.contains(ChartType.MOCA);

        // WMD flag
        if (group.equals("com.redprairie.wmd")) return charts.contains(ChartType.WM);

        // INTEGRATOR flag
        if (group.equals("com.redprairie.seamles")) return charts.contains(ChartType.INTEGRATOR);

        // graph all else -- but only if this was requested
        return charts.contains(ChartType.OTHER);
    }
}
