package com.jda.mad;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.ParseException;
import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

/**
 * Tests for {@link GraphAllProbesFromSupportZip}.
 * <p/>
 * Copyright (c) 2016 JDA Software All Rights Reserved
 *
 * @author mdobrinin
 */
public class TU_GraphAllProbesFromSupportZip {

    @Test
    public void testArgs() throws ParseException {
        CommandLine o = GraphAllProbesFromSupportZip.getOptions(new String[]{"support.zip"});
        assertFalse(o.hasOption('t'));
        assertFalse(o.hasOption('j'));
        assertFalse(o.hasOption('w'));
        assertEquals("support.zip", GraphAllProbesFromSupportZip.getSupportZipArg(o));

        o = GraphAllProbesFromSupportZip.getOptions(new String[]{"-t", "support.zip"});
        assertTrue(o.hasOption('t'));
        assertFalse(o.hasOption('j'));
        assertFalse(o.hasOption('w'));
        assertEquals("support.zip", GraphAllProbesFromSupportZip.getSupportZipArg(o));

        o = GraphAllProbesFromSupportZip.getOptions(new String[]{"-tjw", "support.zip"});
        assertTrue(o.hasOption('t'));
        assertTrue(o.hasOption('j'));
        assertTrue(o.hasOption('w'));
        assertEquals("support.zip", GraphAllProbesFromSupportZip.getSupportZipArg(o));

        o = GraphAllProbesFromSupportZip.getOptions(new String[]{"--tasks", "support.zip"});
        assertTrue(o.hasOption('t'));
        assertFalse(o.hasOption('j'));
        assertFalse(o.hasOption('w'));
        assertEquals("support.zip", GraphAllProbesFromSupportZip.getSupportZipArg(o));
    }

    @Test(expected = IllegalStateException.class)
    public void testInvalidArgs() throws ParseException {
        CommandLine o = GraphAllProbesFromSupportZip.getOptions(new String[]{""});
        assertFalse(o.hasOption('t'));
        assertFalse(o.hasOption('j'));
        assertFalse(o.hasOption('w'));
        assertEquals("support.zip", GraphAllProbesFromSupportZip.getSupportZipArg(o));
    }

    @Test(expected = IllegalStateException.class)
    public void testInvalidArgs2() throws ParseException {
        CommandLine o = GraphAllProbesFromSupportZip.getOptions(new String[]{"-tjw"});
        assertTrue(o.hasOption('t'));
        assertTrue(o.hasOption('j'));
        assertTrue(o.hasOption('w'));
        assertEquals("support.zip", GraphAllProbesFromSupportZip.getSupportZipArg(o));
    }
}