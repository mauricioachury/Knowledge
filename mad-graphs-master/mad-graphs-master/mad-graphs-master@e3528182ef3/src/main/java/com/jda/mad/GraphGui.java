package com.jda.mad;

import java.awt.BorderLayout;
import java.awt.CardLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.io.File;
import java.io.IOException;
import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.List;
import java.util.Map.Entry;
import java.util.TimeZone;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JComponent;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.LookAndFeel;
import javax.swing.SwingConstants;
import javax.swing.UIManager;
import javax.swing.WindowConstants;
import javax.swing.border.Border;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import javax.swing.filechooser.FileNameExtensionFilter;
import javax.swing.plaf.ComboBoxUI;
import javax.swing.plaf.basic.BasicArrowButton;
import javax.swing.plaf.basic.BasicComboBoxUI;

import org.apache.commons.cli.ParseException;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;

import com.jda.mad.graphs.ChartType;
import com.jda.mad.graphs.Grapher;
import com.jda.mad.graphs.Utils;

/**
 * This is a GUI version of the application that lets you select which probes or groups of probes to graph.
 * <p/>
 * Copyright (c) 2016 JDA Software All Rights Reserved
 *
 * @author j1021875
 */
public class GraphGui {

    public static void main(String[] args) throws IOException, ParseException {
        frame = new JFrame("Probe Charts");
        JLabel openingMessage = new JLabel("Use File > Open Support Zip... to view probe data for a support zip file.", SwingConstants.CENTER);
        openingMessage.setFont(new Font("Verdana", Font.PLAIN, 12));
        frame.getContentPane().add(openingMessage);
        frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        createMenu();
        frame.getContentPane().setBackground(Color.WHITE);
        frame.pack();
        frame.setMinimumSize(new Dimension(1200, 500));
        frame.setVisible(true);
    }
    
    private static void createMenu() {
        final JMenuBar menuBar;
        final JMenu menu;
        final JFileChooser fileChooser;
        final JMenuItem zipFileButton;
        try {
            // set look and feel for just menu bar, button, and file chooser
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
            menuBar = new JMenuBar();
            menu = new JMenu("File");
            fileChooser = new JFileChooser();
            fileChooser.setFileFilter(new FileNameExtensionFilter(null, "zip"));
            zipFileButton = new JMenuItem("Open Support Zip...", KeyEvent.VK_T);
            UIManager.setLookAndFeel(originalLF);
            zipFileButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    int returnVal = fileChooser.showOpenDialog((Component) e.getSource());
                    if (returnVal == JFileChooser.APPROVE_OPTION) {
                        File file = fileChooser.getSelectedFile();
                        try {
                            lastChartTypeSelected = ChartType.JVM;
                            String filePath = file.toString();
                            parseZip(filePath, lastChartTypeSelected);
                            supportZip = filePath;
                        }
                        catch (IOException e1) {
                            JOptionPane.showMessageDialog(frame, "Couldn't parse zip.", "Error", JOptionPane.ERROR_MESSAGE);
                        }
                    }
                }
            });
            menuBar.add(menu);
            menu.add(zipFileButton);
            frame.setJMenuBar(menuBar);
        }
        catch (Exception ex) {
            JOptionPane.showMessageDialog(frame, "Couldn't parse zip.", "Error", JOptionPane.ERROR_MESSAGE);
        }
    }
    
    private static void createAndShowGUI(ArrayList<Entry<String, JFreeChart>> charts) {
        final CardLayout cardLayout = new CardLayout(); 
        final JPanel cardPanel = new JPanel(cardLayout);
        final JPanel buttonMenu = new JPanel();
        final GridBagConstraints gbc = new GridBagConstraints();
        final JScrollPane buttonScrollMenu = new JScrollPane(buttonMenu);
        final JComboBox<ChartType> comboBox = new JComboBox<ChartType>(ChartType.values());
        cardPanel.setBackground(Color.WHITE);
        cardPanel.setBorder(new EmptyBorder(10, 5, 10, 10));
        buttonMenu.setBackground(new Color(84,84,84));
        buttonMenu.setLayout(new GridBagLayout());
        buttonScrollMenu.setPreferredSize(new Dimension(500, 500));
        buttonScrollMenu.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
        buttonScrollMenu.getVerticalScrollBar().setUnitIncrement(16);
        gbc.fill = GridBagConstraints.HORIZONTAL;
        gbc.anchor = GridBagConstraints.NORTH;
        gbc.gridwidth = GridBagConstraints.REMAINDER;
        // set arrow color
        comboBox.setUI(ColorArrowUI.createUI(comboBox));
        comboBox.setBackground(new Color(84,84,84));
        comboBox.setForeground(Color.WHITE);
        comboBox.setFont(new Font("Verdana", Font.PLAIN, 12));
        comboBox.setBorder(buttonBorder);
        comboBox.setSelectedItem(lastChartTypeSelected);
        comboBox.setPreferredSize(new Dimension(480, 30));
        comboBox.addActionListener(new ActionListener() {
            @SuppressWarnings("unchecked")
            public void actionPerformed(ActionEvent event) {
                JComboBox<ChartType> combo = (JComboBox<ChartType>) event.getSource();
                ChartType selectedChartType = (ChartType) combo.getSelectedItem();
                try {
                    lastChartTypeSelected = selectedChartType;
                    parseZip(supportZip, lastChartTypeSelected);
                }
                catch (IOException e) {
                    JOptionPane.showMessageDialog(frame, "Couldn't parse zip.", "Error", JOptionPane.ERROR_MESSAGE);
                }
            }
        });
        buttonMenu.add(comboBox, gbc);
        gbc.gridy+=2;
        // add all of the chart buttons to the buttonMenu and charts to cardPanel
        for (final Entry<String, JFreeChart> x : charts) {
            // set system look and feel for chart right clicking
            try {
                UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
                ChartPanel chartCard = new ChartPanel(x.getValue());
                cardPanel.add(chartCard, x.getKey());
                UIManager.setLookAndFeel(originalLF);
            }
            catch (Exception ex) {
                JOptionPane.showMessageDialog(frame, "Error adding charts to chart panel.", "Error", JOptionPane.ERROR_MESSAGE);
            }
            JButton chartButton = new JButton(x.getKey());
            chartButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent event) {
                    cardLayout.show(cardPanel, x.getKey());
                }
            });
            // change color when the mouse enters/leaves the button
            chartButton.addMouseListener(new java.awt.event.MouseAdapter() {
                public void mouseEntered(java.awt.event.MouseEvent event) {
                    JButton chartButton = (JButton) event.getSource();
                    chartButton.setBackground(new Color(127,127,127));
                }
                public void mouseExited(java.awt.event.MouseEvent event) {
                    JButton chartButton = (JButton) event.getSource();
                    chartButton.setBackground(new Color(84,84,84));
                }
            });
            chartButton.setBackground(new Color(84,84,84));
            chartButton.setForeground(Color.WHITE);
            chartButton.setFont(new Font("Verdana", Font.PLAIN, 12));
            chartButton.setFocusPainted(false);
            chartButton.setBorder(buttonBorder);
            chartButton.setPreferredSize(new Dimension(480, 30));
            buttonMenu.add(chartButton, gbc);
            gbc.gridy++;
        }
        // create a dummy component to fill any null space in the buttonMenu
        JLabel dummy = new JLabel(" ");
        dummy.setPreferredSize(new Dimension(1, 1));
        gbc.weighty = 1;
        gbc.gridy++;
        buttonMenu.add(dummy, gbc);
        frame.getContentPane().add(buttonScrollMenu, BorderLayout.WEST);
        frame.getContentPane().add(cardPanel, BorderLayout.CENTER);
        frame.setVisible(true);
    }
    
    private static void parseZip(String supportZip, ChartType chartType) throws IOException {
        // first, clear the frame then process the zip file
        frame.getContentPane().removeAll();
        createMenu();
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
        
        // a list of tuples defined as <metricName, chart>
        ArrayList<Entry<String, JFreeChart>> charts = new ArrayList<Entry<String, JFreeChart>>();

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

                // only graph this probe if it was requested
                if (Utils.filter(strings[0], strings[1], Arrays.asList(chartType))) {
                    final List<String> data = Utils.readEntry(zipFile, entry);
                    if (data.size() >= 2) {
                        JFreeChart chart = Grapher.chartForGUI(strings[0], strings[1], data);
                        // check for null, in which case this was a custom probe. we don't want to include that
                        if (chart != null) charts.add(new AbstractMap.SimpleEntry<>(strings[1], chart));
                    }
                }
            }
        }
        createAndShowGUI(charts);
    }
    
    private static Border buttonBorder = new LineBorder(new Color(35,35,35), 1);
    private static String supportZip;
    private static JFrame frame;
    private static ChartType lastChartTypeSelected;
    private static LookAndFeel originalLF = UIManager.getLookAndFeel();
    
    private static class ColorArrowUI extends BasicComboBoxUI {
        public static ComboBoxUI createUI(JComponent c) {
            return new ColorArrowUI();
        }
        @Override
        protected JButton createArrowButton() {
            BasicArrowButton arrowButton = new BasicArrowButton(
                    BasicArrowButton.SOUTH,
                    new Color(84,84,84), new Color(84,84,84),
                    Color.WHITE, new Color(84,84,84));
            arrowButton.setBorder(new LineBorder(new Color(35,35,35), 1));
            return arrowButton;
        }
    }
}