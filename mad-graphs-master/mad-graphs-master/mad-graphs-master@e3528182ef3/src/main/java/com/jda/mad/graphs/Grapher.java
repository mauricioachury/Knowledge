package com.jda.mad.graphs;

import java.awt.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import java.util.TimeZone;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartFrame;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.XYLineAndShapeRenderer;
import org.jfree.data.general.SeriesException;
import org.jfree.data.time.FixedMillisecond;
import org.jfree.data.time.TimeSeries;
import org.jfree.data.time.TimeSeriesCollection;
import org.jfree.data.time.TimeSeriesDataItem;

/**
 * Class that is able to create graphs for a single probe.
 * <p/>
 * Copyright (c) 2016 JDA Software All Rights Reserved
 *
 * @author mdobrinin
 */
public class Grapher {

    /**
     * Create and launch window with graph of probe data.
     *
     * @param group group name of the probe
     * @param metricName what to graph e.g., value, mean, max. Should be same as column header
     * @param data actual contents of csv file
     * @throws IOException
     */
    public static void chartSingleFile(String group, String metricName, List<String> data) throws IOException {
        _currentFile = group + metricName;

        final String[] lfv = {""};
        final TimeSeriesCollection dataset = getTimeSeries(data, lfv);
        if (dataset == null) return;
        JFreeChart chart = ChartFactory.createTimeSeriesChart(
                metricName,         // title
                "Date",             // x-axis label
                lfv[0],             // y-axis label
                dataset,            // data
                true,               // create legend?
                true,               // generate tooltips?
                false               // generate URLs?
        );
        stylize(chart);

        ChartFrame frame = new ChartFrame(group + " " + metricName, chart);
        frame.pack();
        frame.setVisible(true);
    }
    
    public static JFreeChart chartForGUI(String group, String metricName, List<String> data) throws IOException {
        _currentFile = group + metricName;

        final String[] lfv = {""};
        final TimeSeriesCollection dataset = getTimeSeries(data, lfv);
        if (dataset == null) return null;
        JFreeChart chart = ChartFactory.createTimeSeriesChart(
                metricName,         // title
                "Date",             // x-axis label
                lfv[0],             // y-axis label
                dataset,            // data
                true,               // create legend?
                true,               // generate tooltips?
                false               // generate URLs?
        );
        stylize(chart);

        return chart;
    }

    /**
     * Set the timezone for the grapher. Technically this is set for the whole JVM, but this is intended.
     * The way the graphs are set up, we build the X axis from the default JVM timezone.
     * @param timeZone time zone ID
     */
    public static void setTimeZone(String timeZone) {
        if (timeZone != null && !timeZone.isEmpty()) {
            TimeZone.setDefault(TimeZone.getTimeZone(timeZone));
        }
    }

    /**
     * Set up the chart so it's easy to read.
     *
     * @param chart
     */
    private static void stylize(JFreeChart chart) {
        XYLineAndShapeRenderer renderer = new XYLineAndShapeRenderer() {
            @Override
            public Stroke getItemStroke(int row, int column) {
                return new BasicStroke(2.0f);
            }
        };
        renderer.setBaseShapesVisible(true);
        renderer.setBaseShapesFilled(true);
        renderer.setBaseStroke(new BasicStroke(3));
        ((XYPlot) chart.getPlot()).setRenderer(renderer);
        final int backgroundColor = 238;
        final int lineColor = 30;
        chart.getPlot().setBackgroundPaint(new Color(backgroundColor, backgroundColor, backgroundColor));
        ((XYPlot) chart.getPlot()).setRangeGridlinePaint(new Color(lineColor, lineColor, lineColor));
        ((XYPlot) chart.getPlot()).setDomainGridlinePaint(new Color(lineColor, lineColor, lineColor));
    }

    /**
     * Get time series collection object from csv data
     *
     * @param lines
     * @param leftHandAxisUnit
     * @return
     * @throws IOException
     */
    private static TimeSeriesCollection getTimeSeries(List<String> lines, String[] leftHandAxisUnit) throws IOException {
        final ProbeType t = figureOutType(lines.get(0));
        // custom probes just return null since we don't want to graph them
        if (t.equals(ProbeType.CUSTOM)) return null;
        final Map<String, TimeSeries> data = new HashMap<>();
        final TimeSeriesCollection ret = new TimeSeriesCollection();

        // first line only used for identification
        lines.remove(0);
        for (String line : lines) {
            _currentLine = line;
            try {
                fillTimeSeriesData(data, line, t, leftHandAxisUnit);
            }
            catch (NumberFormatException e) {
                //ignore and keep going
            }
            catch (SeriesException e) {
                // log a warning for these, may want to fix eventually
                // System.err.println("Error graphing [" + _currentFile + "] on line [" + _currentLine + "]");
                // e.printStackTrace();
            }
        }
        for (Map.Entry<String, TimeSeries> entry : data.entrySet()) {
            ret.addSeries(entry.getValue());
        }
        return ret;
    }

    /**
     * Figure out the type of the probe based on the header.
     * @param line
     * @return
     */
    private static ProbeType figureOutType(String line) {
        // there are two versions of the headers in the wild
        // additionally, it may be a probe WITH CONTEXT, which means additional columns
        // however here we simply check if it starts with the base columns as we don't have support for the context yet
        final String s = line.trim().toLowerCase(Locale.ENGLISH);
        if (s.equals(GAUGE_HEADER.toLowerCase(Locale.ENGLISH))) {
            return ProbeType.GAUGE;
        }
        else if (s.equals(COUNTER_HEADER.toLowerCase(Locale.ENGLISH))) {
            return ProbeType.COUNTER;
        }
        else if (s.startsWith(METER_HEADER.toLowerCase(Locale.ENGLISH)) || s.startsWith(METER_HEADER_V2.toLowerCase(Locale.ENGLISH))) {
            return ProbeType.METER;
        }
        else if (s.startsWith(HISTOGRAM_HEADER.toLowerCase(Locale.ENGLISH)) || s.startsWith(HISTOGRAM_HEADER_V2.toLowerCase(Locale.ENGLISH))) {
            return ProbeType.HISTOGRAM;
        }
        else if (s.equals(HISTOGRAM_CTX_HEADER.toLowerCase(Locale.ENGLISH))) {
            return ProbeType.HISTOGRAM_CTX;
        }
        else if (s.startsWith(TIMER_HEADER.toLowerCase(Locale.ENGLISH)) || s.startsWith(TIMER_HEADER_V2.toLowerCase(Locale.ENGLISH))) {
            return ProbeType.TIMER;
        }
        else {
            // we assume that any other information is just a custom probe, and we ignore it for now
            return ProbeType.CUSTOM;
        }
    }

    /**
     * Figure out which columns actually get displayed on the graph.
     *
     * @param data
     * @param line
     * @param type
     * @param leftHandAxisUnit
     */
    private static void fillTimeSeriesData(Map<String, TimeSeries> data, String line, ProbeType type, String[] leftHandAxisUnit) {
        String[] parts = line.split(",");
        switch (type) {
            case COUNTER: {
                if (data.get("count") == null) data.put("count", new TimeSeries("count"));
                data.get("count").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[1])));
                leftHandAxisUnit[0] = "count";
                break;
            }
            case GAUGE: {
                if (data.get("value") == null) data.put("value", new TimeSeries("value"));
                data.get("value").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[1])));
                leftHandAxisUnit[0] = "value";
                break;
            }
            case HISTOGRAM: {
                if (data.get("max") == null) data.put("max", new TimeSeries("max"));
                if (data.get("mean") == null) data.put("mean", new TimeSeries("mean"));
                if (data.get("min") == null) data.put("min", new TimeSeries("min"));
                if (data.get("p50") == null) data.put("p50", new TimeSeries("p50"));
                if (data.get("p75") == null) data.put("p75", new TimeSeries("p75"));
                if (data.get("p95") == null) data.put("p95", new TimeSeries("p95"));
                if (data.get("p98") == null) data.put("p98", new TimeSeries("p98"));
                if (data.get("p99") == null) data.put("p99", new TimeSeries("p99"));
                if (data.get("p999") == null) data.put("p999", new TimeSeries("p999"));
                data.get("max").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[2])));
                data.get("mean").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[3])));
                data.get("min").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[4])));
                data.get("p50").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[6])));
                data.get("p75").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[7])));
                data.get("p95").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[8])));
                data.get("p98").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[9])));
                data.get("p99").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[10])));
                data.get("p999").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[11])));
                leftHandAxisUnit[0] = "value";
                break;
            }
            case HISTOGRAM_CTX: {
                if (data.get("max") == null) data.put("max", new TimeSeries("max"));
                if (data.get("mean") == null) data.put("mean", new TimeSeries("mean"));
                if (data.get("min") == null) data.put("min", new TimeSeries("min"));
                if (data.get("p50") == null) data.put("p50", new TimeSeries("p50"));
                if (data.get("p75") == null) data.put("p75", new TimeSeries("p75"));
                if (data.get("p95") == null) data.put("p95", new TimeSeries("p95"));
                if (data.get("p98") == null) data.put("p98", new TimeSeries("p98"));
                if (data.get("p99") == null) data.put("p99", new TimeSeries("p99"));
                if (data.get("p999") == null) data.put("p999", new TimeSeries("p999"));
                data.get("max").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[4])));
                data.get("mean").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[5])));
                data.get("min").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[6])));
                data.get("p50").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[7])));
                // no stddev
                data.get("p75").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[9])));
                data.get("p95").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[10])));
                data.get("p98").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[11])));
                data.get("p99").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[12])));
                data.get("p999").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[13])));
                leftHandAxisUnit[0] = "value";
                break;
            }
            case TIMER: {
                if (data.get("max") == null) data.put("max", new TimeSeries("max"));
                if (data.get("mean") == null) data.put("mean", new TimeSeries("mean"));
                if (data.get("min") == null) data.put("min", new TimeSeries("min"));
                if (data.get("p50") == null) data.put("p50", new TimeSeries("p50"));
                if (data.get("p75") == null) data.put("p75", new TimeSeries("p75"));
                if (data.get("p95") == null) data.put("p95", new TimeSeries("p95"));
                if (data.get("p98") == null) data.put("p98", new TimeSeries("p98"));
                if (data.get("p99") == null) data.put("p99", new TimeSeries("p99"));
                if (data.get("p999") == null) data.put("p999", new TimeSeries("p999"));
                data.get("max").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[2])));
                data.get("mean").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[3])));
                data.get("min").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[4])));
                data.get("p50").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[6])));
                data.get("p75").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[7])));
                data.get("p95").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[8])));
                data.get("p98").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[9])));
                data.get("p99").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[10])));
                data.get("p999").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[11])));
                leftHandAxisUnit[0] = "value";
                break;
            }
            case METER: {
                if (data.get("mean_rate") == null) data.put("mean_rate", new TimeSeries("mean_rate"));
                if (data.get("m1_rate") == null) data.put("m1_rate", new TimeSeries("m1_rate"));
                if (data.get("m5_rate") == null) data.put("m5_rate", new TimeSeries("m5_rate"));
                if (data.get("m15_rate") == null) data.put("m15_rate", new TimeSeries("m15_rate"));
                data.get("mean_rate").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[2])));
                data.get("m1_rate").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[3])));
                data.get("m5_rate").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[4])));
                data.get("m15_rate").add(new TimeSeriesDataItem(new FixedMillisecond(Long.parseLong(parts[0])), Double.valueOf(parts[5])));
                leftHandAxisUnit[0] = "time-value";
                break;
            }
            default:
                throw new RuntimeException("Unknown type {" + type + "}");
        }
    }

    private enum ProbeType {
        /**
         * timestamp,count,max,mean,min,stddev,p50,p75,p95,p98,p99,p999
         */
        HISTOGRAM,
        /**
         * timestamp,Count,MaxContext,MinContext,Max,Mean,Min,StdDev,50thPercentile,75thPercentile,95thPercentile,98thPercentile,99thPercentile,999thPercentile
         */
        HISTOGRAM_CTX,
        /**
         * timestamp,count,max,mean,min,stddev,p50,p75,p95,p98,p99,p999,mean_rate,m1_rate,m5_rate,m15_rate,rate_unit,duration_unit
         */
        TIMER,
        /**
         * timestamp,value
         */
        GAUGE,
        /**
         * timestamp,count
         */
        COUNTER,
        /**
         * timestamp,count,mean_rate,m1_rate,m5_rate,m15_rate,rate_unit
         */
        METER,
        CUSTOM
    }

    static final String GAUGE_HEADER = "timestamp,value";
    static final String COUNTER_HEADER = "timestamp,count";
    static final String METER_HEADER =    "timestamp,count,mean_rate,m1_rate,m5_rate,m15_rate,rate_unit";
    static final String METER_HEADER_V2 = "timestamp,Count,MeanRate,OneMinuteRate,FiveMinuteRate,FifteenMinuteRate,RateUnit";
    static final String HISTOGRAM_HEADER =    "timestamp,count,max,mean,min,stddev,p50,p75,p95,p98,p99,p999";
    static final String HISTOGRAM_HEADER_V2 = "timestamp,Count,Max,Mean,Min,StdDev,50thPercentile,75thPercentile,95thPercentile,98thPercentile,99thPercentile,999thPercentile";
    static final String HISTOGRAM_CTX_HEADER = "timestamp,Count,MaxContext,MinContext,Max,Mean,Min,StdDev,50thPercentile,75thPercentile,95thPercentile,98thPercentile,99thPercentile,999thPercentile";
    static final String TIMER_HEADER =    "timestamp,count,max,mean,min,stddev,p50,p75,p95,p98,p99,p999,mean_rate,m1_rate,m5_rate,m15_rate,rate_unit,duration_unit";
    static final String TIMER_HEADER_V2 = "timestamp,Count,Max,Mean,Min,StdDev,50thPercentile,75thPercentile,95thPercentile,98thPercentile,99thPercentile,999thPercentile,MeanRate,OneMinuteRate,FiveMinuteRate,FifteenMinuteRate,RateUnit,DurationUnit";

    /**
     * Keeps track of the current probe we are parsing/graphing. Mostly just used for better exceptions.
     */
    private static volatile String _currentFile;
    /**
     * Keeps track of the current line we are parsing/graphing. Mostly just used for better exceptions.
     */
    private static volatile String _currentLine;
}
