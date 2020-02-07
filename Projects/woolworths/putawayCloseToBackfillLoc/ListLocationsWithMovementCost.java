/*
 *  $URL$
 *  $Author$
 *  $Date$
 *
 *  $Copyright-Start$
 *
 *  Copyright (c) 2011
 *  RedPrairie Corporation
 *  All Rights Reserved
 *
 *  This software is furnished under a corporate license for use on a
 *  single computer system and can be copied (with inclusion of the
 *  above copyright) only for use on such a system.
 *
 *  The information in this document is subject to change without notice
 *  and should not be construed as a commitment by RedPrairie Corporation.
 *
 *  RedPrairie Corporation assumes no responsibility for the use of the
 *  software described in this document on equipment which has not been
 *  supplied or approved by RedPrairie Corporation.
 *
 *  $Copyright-End$
 */

package com.redprairie.wmd.intrinsic;

import com.google.common.collect.ComputationException;
import com.redprairie.mcs.MissingArgumentException;
import com.redprairie.mcs.Policy;
import com.redprairie.moca.ColumnNotFoundException;
import com.redprairie.moca.EditableResults;
import com.redprairie.moca.MocaArgument;
import com.redprairie.moca.MocaContext;
import com.redprairie.moca.MocaException;
import com.redprairie.moca.MocaResults;
import com.redprairie.moca.MocaType;
import com.redprairie.moca.NotFoundException;
import com.redprairie.moca.SimpleResults;
import com.redprairie.moca.components.base.CoreService;
import com.redprairie.moca.util.MocaUtils;
import com.redprairie.wmd.WMDConstants;
import com.redprairie.wmd.policies.PolicyUtils;

import autovalue.shaded.org.apache.commons.lang.StringUtils;



/**
 * A class that implements <b><i>list locations with movement cost</i></b> MOCA
 * component library.
 *
 * <pre>
 * Copyright (c) 2011 RedPrairie Corporation
 * All Rights Reserved
 * </pre>
 *
 * @author $Author$
 * @version $Revision$
 */
public class ListLocationsWithMovementCost {

    // Initialize the variables that will keep track of values for previous
    // location's parameters, which will be  passed in to the next call
    // to LMS. This will ensure that we call LMS command in the most
    // optimal way.
    private int xSrcToUse = -1;
    private int ySrcToUse = -1;
    private int srcDistToToInt = -1;
    private int srcDistToFromInt = -1;
    private int srcFromIntersIntId = -1;
    private int srcToIntersIntId = -1;

    /**
     * Prime constructor that creates a new instance of
     * {@link ListLocationsWithMovementCost} class.
     */
    public ListLocationsWithMovementCost() {
        this(MocaUtils.currentContext());
    }

    /**
     * Constructor that creates a new instance of
     * {@link ListLocationsWithMovementCost} class
     * with the given moca context.
     */
    public ListLocationsWithMovementCost(MocaContext context) {
        _moca = context;
    }

    /**
     * Represents the main execution point for <b><i>list locations with
     * movement cost</i></b> MOCA component.<br><br>
     *
     * This command will calculate the distance between locations using the LMS
     * product. This command can in execute in two modes: result set mode and
     * non-result set mode. If a result set is passed it will tack on the
     * distances as a new column. If a from location is passed, it will return
     * one distance.
     *
     * @param inResSet Input Result Set
     * @param fromLoc From Location
     * @param toLoc To Location
     * @param whId Warehouse Identifier
     * @param useStoSeq If this is passed in as 1, this command will calculate
     *     locations with movement cost according to storage sequence if it
     *     is defined rather than travel sequence.  If no storage sequence is
     *     defined, travel sequence will be used.
     *
     * @throws MocaException Thrown if LMS is not installed, the appropriate
     *             policy configuration(s) are not found, invalid arguments are
     *             passed in, etc.
     *
     * @return MocaResults containing movement_cost.
     */
    public MocaResults execListLocationsWithMovementCost(MocaResults inResSet,
            String fromLoc, String toLoc, String whId, Integer useStoSeq) throws MocaException {

        if (useStoSeq == null) {
            _moca.trace("use_sto_seq not passed in, assuming the caller " +
               "does not want to use storage sequences.");

            useStoSeq = 0;
        }

        validateInput(inResSet, fromLoc, toLoc, whId);
        setVehicleType(whId);

        try {

        // Let's check to see if 'LABOR-MANAGEMENT-SYSTEM' policy is installed!
        // in MocaCache.
        // NOTE: this policy is stored in MocaCache object, which is maintained
        // at the warehouse level by a first MOCA client that queries the MOCA
        // server for this policy. Thus, we only retrieve this policy info once
        // for all users in the warehouse by avoid making multiple db trips.
        // If the LMS policy is not installed, then an exception will be thrown
        // from calling PolicyUtils.isPolicyModuleInstalled() to the caller.
        if (getPolicyUtilsInstance().isPolicyModuleInstalled(
            WMDConstants.POLCOD_LMS, whId)) {

            // Get the time limit for acceptable delay that we will wait for
            // remote LMS calls to complete, which is stored in the policy
            // below. Once retrieved, this policy configuration will be stored
            // at the MOCA server level.
            Policy policy = getPolicyUtilsInstance().getPolicy(
                WMDConstants.POLCOD_LMS,
                WMDConstants.POLVAR_CONFIGURATION,
                WMDConstants.POLVAL_ACCEPTABLE_DELAY, whId);
            int acceptableDelay = policy.getRtNum1();

            // Get the remote string for LMS system, which is stored in the
            // policy below. Once retrieved, this policy configuration will be
            // stored at the MOCA server level.
            policy = getPolicyUtilsInstance().getPolicy(
                WMDConstants.POLCOD_LMS,
                WMDConstants.POLVAR_CONFIGURATION,
                WMDConstants.POLVAL_REMOTE_MOCA_INFORMATION, whId);
            String lmsRemoteString = policy.getRtStr1();

            // This command supports a few modes of operation. The user can pass
            // in a result set and a from or two location or they can pass in a
            // from and to location. If they pass in a result set it will run
            // the from or to location against all the locations in that result
            // set. The incoming result set should have movement_cost and stoloc
            // as column names but may contain others as well.

                if (inResSet != null && inResSet.getRowCount() > 0) {
                    _moca.trace("Command [list locations with movement "
                        + "cost] is executing in result set mode...");
                    return executeResultSetMode(inResSet, lmsRemoteString,
                               fromLoc,
                        whId, acceptableDelay, useStoSeq);
                }
                else {
                    _moca.trace("Command [list locations with movement cost]"
                        + " is NOT executing in result set mode. We "
                        + "must provide from_loc and to_loc args...");
                    return executeNonResultSetMode(lmsRemoteString, fromLoc,
                        toLoc, whId, useStoSeq);
                }
            }
            else {

                // LMS is not installed, so return the default results with
                // movement_cost
                if (inResSet != null && inResSet.getRowCount() > 0) {
                    _moca.trace("Command [list locations with movement cost]"
                        + " is executing in result set mode...");
                    return getDefaultDiscreteDistanceWithResultSet(fromLoc,
                        inResSet, whId, useStoSeq);
                }
                else {
                    _moca.trace("Command [list locations with movement cost]"
                        + " is NOT executing in result set mode. We must"
                        + " provide from_loc and to_loc args...");
                    return getDefaultDiscreteDistance(fromLoc,
                        toLoc, whId, useStoSeq);
                }

            }
        } // end try
        catch (ComputationException e) {
            //Policy data is missing so we can't tell if LM
            //is installed. Log an error and do the best we can
            //without this info

            _moca.trace("WARNING!! Missing policy data! "
                        + e.getCause() + " - " + e.toString());

            if (inResSet != null && inResSet.getRowCount() > 0) {
                _moca.trace("Command [list locations with movement cost] is "
                    + "executing in result set mode...");
                return getDefaultDiscreteDistanceWithResultSet(fromLoc,
                    inResSet,
                    whId,
                    useStoSeq);
            }
            else {
                _moca.trace("Command [list locations with movement cost] is "
                    + "NOT executing in result set mode. We must provide "
                    + "from_loc and to_loc args...");
                return getDefaultDiscreteDistance(fromLoc,
                    toLoc,
                    whId,
                    useStoSeq);
            }
        }
        catch (MocaException e) {
            //Policy data is missing so we can't tell if LM
            //is installed. Log an error and do the best we can
            //without this info
            //need this incase the policy reader is called directly

            _moca.trace("WARNING!! Missing policy data! "
                        + e.getCause() + " - " + e.toString());

            if (inResSet != null && inResSet.getRowCount() > 0) {
                _moca.trace("Command [list locations with movement cost] is "
                    + "executing in result set mode...");
                return getDefaultDiscreteDistanceWithResultSet(fromLoc,
                    inResSet,
                    whId,
                    useStoSeq);
            }
            else {
                _moca.trace("Command [list locations with movement cost] is "
                    + "NOT executing in result set mode. We must provide "
                    + "from_loc and to_loc args...");
                return getDefaultDiscreteDistance(fromLoc,
                    toLoc,
                    whId,
                    useStoSeq);
            }
        }
    }

    /**
     * Method to validate input parameters.
     * If we were passed a result set, it needs
     * to have the proper columns. If there is no
     * result set, we need both to and from locations.
     *
     * @param inResSet MocaResults given from calling code
     * @param fromLoc From Location
     * @param toLoc To Location
     * @param whId Warehouse Identifier
     *
     * @throws MissingArgumentException - The proper inputs are not
     *                                    provided or the result set does not
     *                                    have the correct columns.
     */
    private void validateInput(MocaResults inResSet, String fromLoc,
                               String toLoc, String whId)
                                       throws MissingArgumentException {

        // Sanity check for an early exit
        if (whId == null || whId.isEmpty()) {
            throw new MissingArgumentException("wh_id");
        }

        if (inResSet != null && inResSet.getRowCount() > 0) {

            // from_loc is required
            if (fromLoc == null || fromLoc.isEmpty()) {
                throw new MissingArgumentException("from_loc");
            }

            // stoloc is required
            if (!inResSet.containsColumn("stoloc")) {
                throw new MissingArgumentException("stoloc");
            }
        }
        else {

            // no result set so we need both to_loc and from_loc
            if (fromLoc == null || fromLoc.isEmpty()) {
                throw new MissingArgumentException("from_loc");
            }
            if (toLoc == null || toLoc.isEmpty()) {
                throw new MissingArgumentException("to_loc");
            }
        }
    }

    /**
     * Executes the command in result set mode.
     *
     * @param inputResultSet MocaResults
     * @param lmsRemoteString Remote String to LMS System
     * @param fromLoc From Location
     * @param whId Warehouse Identifier
     * @param acceptableDelayLimit Acceptable Delay for LM Calculation
     * @param useStoSeq Use Storage Sequence
     *
     * @return MocaResults - i.e. Input MocaResults along with an additional
     *                                  movement_cost column.
     * @throws MocaException 
     */
    private MocaResults executeResultSetMode(MocaResults inputResultSet,
           String lmsRemoteString, String fromLoc, String whId,
           int acceptableDelayLimit, Integer useStoSeq) throws MocaException {

        // First, let's copy the passed-in result set into our editable return
        // results structure, which will allow us to reset the value for
        // 'movement_cost' column calculated by calculate discrete distance.
        EditableResults rs = new SimpleResults();
        rs = (EditableResults) inputResultSet;

        rs.next();

        // Call LMS once in non-result set mode to
        // set our optimization variables so when we
        // call LMS with result set it is efficient
        // Variables that should be initialized are:
        //     int xSrcToUse
        //     int ySrcToUse
        //     int srcDistToToInt
        //     int srcDistToFromInt
        //     int srcFromIntersIntId
        //     int srcToIntersIntId
        calculateDiscreteDistance(
            lmsRemoteString, fromLoc, fromLoc, whId, useStoSeq);

        // Now that our optimization variables are set,
        // we can calculate the distances on the result set
        MocaResults outRes = calculateDiscreteDistanceWithResultSet(rs,
            lmsRemoteString, fromLoc, whId, acceptableDelayLimit,
            useStoSeq);

        return outRes;
    }

    /**
     * Executes the command in non-result set mode.
     *
     * @param lmsRemoteString Remote string to LMS system
     * @param fromLoc From location
     * @param toLoc To location
     * @param whId Warehouse Identifier
     * @param useStoSeq Use Storage Sequence
     *
     * @throws MocaException Thrown if LMS is not installed, the appropriate
     *             policy configuration(s) are not found, failure occurs while
     *             communicating with remote LMS host, etc.
     *
     * @return MocaResults containing movement cost column.
     */
    private MocaResults executeNonResultSetMode(String lmsRemoteString,
            String fromLoc, String toLoc, String whId, Integer useStoSeq)
        throws MocaException {

        // Sanity check for invalid arguments passed in. In non-result set mode,
        // the following args are required in order for execution to proceed.
        if (fromLoc == null || fromLoc.isEmpty()) {
            _moca.trace("In non-result set mode for 'list locations with "
                + "movement cost' component, from_loc argument is required!");
            throw new MissingArgumentException("from_loc");
        }
        else if (toLoc == null || toLoc.isEmpty()) {
            _moca.trace("In non-result set mode for 'list locations with "
                + "movement cost' component, to_loc argument is required!");
            throw new MissingArgumentException("to_loc");
        }

        return calculateDiscreteDistance(lmsRemoteString, fromLoc, toLoc, whId,
            useStoSeq);
    }

    /**
     * Calculates the discrete distance for a set of locations
     * by making a remote call to LMS.
     *
     * @param locSet The set of locations
     *            that need to have movement cost calculated
     * @param lmsRemoteString Remote string to LMS system
     * @param fromLoc From Location
     * @param whId Warehouse Identifier
     * @param acceptableDelay Acceptable delay in milliseconds
     * @param useStoSeq Use Storage Sequence
     *
     * @return MocaResults containing movement_cost column.
     */
    protected MocaResults calculateDiscreteDistanceWithResultSet(
                                                        MocaResults locSet,
                                                        String lmsRemoteString,
                                                        String fromLoc,
                                                        String whId,
                                                        int acceptableDelay,
                                                        Integer useStoSeq) {

        // First, let's initialize the default structure for results to be
        // returned. The default structure will be returned to the caller
        // if we encounter any MocaException while making a remote call to LMS.
        // This default structure will contain results sorted by movement_cost
        // according to wm so that good locations are calculated first.
        EditableResults returnRes =
                getDefaultDiscreteDistanceWithResultSet(fromLoc,
                                                        locSet,
                                                        whId,
                                                        useStoSeq);
        returnRes.reset();

        String cmd = " remote('" + lmsRemoteString + "') "
            + " { "
            + "     publish data where start_time = [[ System.nanoTime() ]]"
            //acceptableDelay is in milliseconds
            //let's use nanoseconds so we can work
            //with a System.nanoTime() later
            + "              and nano_seconds_threshold = " + acceptableDelay * 1000000.0
            + "     | "
            + "     publish data combination "
            + "        where res1 = @locSet "
            + "     | "
            //only do the calculation if we're not over our
            //time threshold
            + "     if ([[ System.nanoTime() ]] < @start_time "
            + "            + @nano_seconds_threshold)"
            + "     {"
            + "         calculate discrete distance "
            + "            where Previous_Slot_Id          = '" + fromLoc + "'"
            + "              and machineid                 = '" + vehType + "'"
            + "              and Current_Slot_Id           = @to_loc "
            + "              and Warehouse_id              = '" + whId + "'"
            + "              and park_point                = 0"
            + "              and src_x_to_use              = " + xSrcToUse
            + "              and src_y_to_use              = " + ySrcToUse
            + "              and src_dist_to_to_int        = " + srcDistToToInt
            + "              and src_dist_to_from_int      = " + srcDistToFromInt
            + "              and src_from_intersect_int_id = " + srcFromIntersIntId
            + "              and src_to_intersect_int_id   = " + srcToIntersIntId

            + "         |                                                    "
            //we only need a couple columns, so save some
            //time by ditching all those columns lm comes back with
            + "         publish data                                         "
            + "             where travel_distance = @travel_distance         "
            + "                        and stoloc = @to_loc                  "
            + "     }                                                        "
            + " } ";

        try {
            MocaArgument argLocSet = new MocaArgument("locSet", getTopLocations(returnRes, whId));
            MocaResults rs = _moca.executeCommand(cmd, argLocSet);
            while (returnRes.hasNext()) {

                returnRes.next();

                // Default value for if we don't have a movement cost calculated
                Double movementCost = (double)MAX_MOVEMENT_COST;
                if (rs.hasNext()) {
                    // We have a movement cost calculated, pull that in
                    rs.next();
                    movementCost = rs.getDouble("travel_distance");
                }
                returnRes.setDoubleValue("movement_cost", movementCost);

                _moca.trace("Setting movement_cost value to [" + movementCost
                    + "] for " + "from_loc ["
                        + returnRes.getString("from_loc") + "] "
                    + "to_loc [" + returnRes.getString("to_loc") + "].");
            }
        }
        catch (MocaException e) {
            // If an error occurs in the remote call we aren't going to bomb
            // out of the command.  We will throw an EMS event to make sure
            // someone knows the error happened since it is most likely an LMS
            // data setup issue. In this case, we will return the default
            // MocaResults structure to the caller.
            _moca.trace("Error in remote call!");
            _moca.trace("Unable to retrieve discrete distance (i.e. movement_"
                + "cost column, etc.) by talking to LMS! ERROR: "
                + e.toString() + " - " + e.getMessage() + ".");
            _moca.trace("Setting movement_cost value to MAX_MOVEMENT_COST ["
                + MAX_MOVEMENT_COST + "] for from_loc [" + fromLoc + "].");

            // Let's raise the EMS event.
            raiseEmsEvent(cmd, e.getErrorCode(), whId);
        }

        return returnRes;
    }

    /**
     * Calculates the discrete distance by making a remote call to LMS.
     *
     * @param lmsRemoteString Remote string to LMS system
     * @param fromLoc From Location
     * @param toLoc To Location
     * @param whId Warehouse Identifier
     * @param useStoSeq Use Storage Sequence
     *
     * @return MocaResults containing movement_cost column.
     * @throws MocaException 
     */
    private MocaResults calculateDiscreteDistance(String lmsRemoteString,
             String fromLoc, String toLoc, String whId, Integer useStoSeq) throws MocaException {

        // First, let's initialize the default structure for results to be
        // returned. The default structure will be returned to the caller
        // if we encounter any MocaException while making a remote call to LMS.
        EditableResults returnRes = getDefaultDiscreteDistance(fromLoc,
                                                               toLoc,
                                                               whId,
                                                               useStoSeq);

        String cmd = "";

        try {
            cmd = "remote('" + lmsRemoteString + "') "
                + "calculate discrete distance "
                + "    where Previous_Slot_Id          = '" + fromLoc + "'"
                + "      and machineid                 = '" + vehType + "'"
                + "      and Current_Slot_Id           = '" + toLoc + "'"
                + "      and Warehouse_id              = '" + whId + "'"
                + "      and park_point                = 0"
                + "      and src_x_to_use              = " + xSrcToUse
                + "      and src_y_to_use              = " + ySrcToUse
                + "      and src_dist_to_to_int        = " + srcDistToToInt
                + "      and src_dist_to_from_int      = " + srcDistToFromInt
                + "      and src_from_intersect_int_id = " + srcFromIntersIntId
                + "      and src_to_intersect_int_id   = " + srcToIntersIntId;

            MocaResults rs = _moca.executeCommand(cmd);

            rs.next();

            // OK, let's set the values for return structure.
            Double movementCost = rs.getDouble("travel_distance");
            returnRes.setDoubleValue("movement_cost", movementCost);

            // In order to make the most optimal call to LMS next time
            // we need to pass along the following arguments.
            // This is because the "calculate discrete distance" component is
            // designed to skip calculating distances from the beginning and
            // end of an aisle containing the previous_slot_id
            // location if the this data is already passed from the previous
            // call to the next call.
            xSrcToUse = rs.getInt("src_x_to_use");
            ySrcToUse = rs.getInt("src_y_to_use");
            srcDistToToInt = rs.getInt("src_dist_to_to_int");
            srcDistToFromInt = rs.getInt("src_dist_to_from_int");
            srcFromIntersIntId =
                rs.getInt("src_from_intersect_int_id");
            srcToIntersIntId = rs.getInt("src_to_intersect_int_id");

            _moca.trace("Setting movement_cost value to [" + movementCost
                + "] for from_loc [" + fromLoc + "].");
        }
        catch (MocaException e) {
            // If an error occurs in the remote call we aren't going to bomb
            // out of the command.  We will throw an EMS event to make sure
            // someone knows the error happened since it is most likely an LMS
            // data setup issue. In this case, we will return the default
            // MocaResults structure to the caller.
            _moca.trace("Error in remote call!");
            _moca.trace("Unable to retrieve discrete distance (i.e. movement_"
                + "cost column, etc.) by talking to LMS! ERROR: "
                + e.getErrorCode() + " - " + e.getMessage() + ".");
            _moca.trace("Setting movement_cost value to MAX_MOVEMENT_COST ["
                + MAX_MOVEMENT_COST + "] for from_loc [" + fromLoc + "].");

            // Let's raise the EMS event.
            raiseEmsEvent(cmd, e.getErrorCode(), whId);
        }

        return returnRes;
    }

    /**
     * Returns Backfill location if any.
     *
     * @param stoloc Location
     * @param whId Warehouse Identifier
     *
     * @return String - Backfill location
     * @throws MocaException 
     */
    private String getBackfillLocaiton(String stoloc,String whId) throws MocaException
    {
        String bckfillLoc = null;
        _moca.trace("getting back fill location for "+ stoloc);
        
        try(MocaResults rs = _moca.executeCommand("   get backfill location "
                                                   +"      where stoloc = @stoloc"
                                                   +"       and wh_id = @whId",
                                                   new MocaArgument("stoloc", stoloc),
                                                   new MocaArgument("wh_id", whId)))
        {         
            if(rs.getRowCount() > 0)
            {
                bckfillLoc = rs.getString("bckfill_loc");
            }
        }
        catch(NotFoundException ne)
        {
            // do nothing as there is no backfill location configured.
        }
        catch(MocaException e)
        {
            _moca.trace("Failed to get back fill location");
            throw new MocaException(e.getErrorCode());
        }
        return bckfillLoc;
        
    }
    /**
     * Returns a default results structure for calculating discrete distance.
     *
     * @param fromLoc From Location
     * @param toLoc To Location
     * @param whId Warehouse Identifier
     * @param useStoSeq Use Storage Sequence
     *
     * @return EditableResults - The default results structure for calculating
     *         discrete distance.
     * @throws MocaException 
     */
    private EditableResults getDefaultDiscreteDistance(String fromLoc,
                                                       String toLoc,
                                                       String whId,
                                                       Integer useStoSeq) throws MocaException {
        String fromSequence = null;
        String toSequence = null;
        EditableResults rs = new SimpleResults();
        String bckfillLoc = null;
        
        if(!fromLoc.equals(toLoc))
        {
        	bckfillLoc = getBackfillLocaiton(toLoc,whId);
        }       
        
        try {
            fromSequence = getLocationSequence(fromLoc, whId, useStoSeq);
        }
        catch (MocaException e) {
            _moca.trace("Failed to select Source ('" + fromLoc
                + "') Travel Sequence! "
                + "ERROR: " + e.getErrorCode() + " - " + e.getMessage() + ".");
        }

        try {
            toSequence = getLocationSequence(toLoc, whId, useStoSeq);
        }
        catch (MocaException e) {
            _moca.trace("Failed to select Destination ('"+ toLoc
                + "') Travel Sequence! "
                + "ERROR: " + e.getErrorCode() + " - " + e.getMessage() + ".");
        }

        // Create the default results structure
        rs.addColumn("from_loc", MocaType.STRING);
        rs.addColumn("to_loc", MocaType.STRING);
        rs.addColumn("movement_cost", MocaType.DOUBLE);

        rs.addRow();
        rs.setStringValue("from_loc", fromLoc);
        
        if(StringUtils.isNotEmpty(bckfillLoc))
        {
            rs.setStringValue("to_loc", bckfillLoc);
        }
        else
        {
            rs.setStringValue("to_loc", toLoc);
        }

        try {
            rs.setDoubleValue("movement_cost",
                    calculateTrvSeq(fromSequence, toSequence));
        }
        catch (NumberFormatException e) {
            // we cannot calculate movement cost if travel sequence
            // is not numeric so set it to the max
            _moca.trace("NumberFormatException raised - default to MAX MOVEMENT COST");
            rs.setDoubleValue("movement_cost", MAX_MOVEMENT_COST);
        }

        return rs;
    }

    /**
     * Returns a default results structure for calculating discrete distance.
     *
     * @param fromLoc From Location
     * @param locSet Set of candidate locations
     * @param whId Warehouse Identifier
     * @param useStoSeq Use Storage Sequence
     *
     * @return EditableResults - The default results structure for calculating
     *         discrete distance, which includes distance calculated from wm
     *         travel sequence
     */
    protected EditableResults getDefaultDiscreteDistanceWithResultSet(
                                String fromLoc,
                                MocaResults locSet,
                                String whId,
                                Integer useStoSeq) {

        String fromSequence = null;
        String toSequence = null;
        EditableResults rs = new SimpleResults();
        rs = (EditableResults) locSet;
        rs.reset();

        try {
            fromSequence = getLocationSequence(fromLoc, whId, useStoSeq);
        }
        catch (MocaException e) {
            _moca.trace("Failed to select Source ('" + fromLoc
                    + "') Travel Sequence! "
                    + "ERROR: " + e.getErrorCode() + " - "
                    + e.getMessage() + ".");
        }

        // Create the default results structure
        rs.addColumn("from_loc", MocaType.STRING);
        rs.addColumn("to_loc", MocaType.STRING);
        rs.addColumn("movement_cost", MocaType.DOUBLE);

        // loop through the input result set and populate
        // the movement_cost according to WM.
        while (rs.hasNext()) {
            rs.next();
            rs.setStringValue("from_loc", fromLoc);
            
            if (rs.containsColumn("bckfill_loc") && rs.containsColumn("bckfill_flg"))
            {
                String bckfillLoc = rs.getString("bckfill_loc");
                if(rs.getInt("bckfill_flg") == 1 && StringUtils.isNotEmpty(bckfillLoc))
                {
                    rs.setStringValue("to_loc", rs.getString("bckfill_loc"));
                }
                else
                {
                    rs.setStringValue("to_loc", rs.getString("stoloc"));    
                }
            }
            else
            {
                rs.setStringValue("to_loc", rs.getString("stoloc"));
            }
            
            // stoloc is required
            
            if (useStoSeq.equals(1) &&
                    !rs.getString("sto_seq").equals(WMDConstants.STORAGE_SEQUENCE_NOT_DEFINED)) {
                toSequence = rs.getString("sto_seq");
            }
            else {
                toSequence = rs.getString("trvseq");
            }

            try {
                // Set the movement_cost according to WM
                rs.setDoubleValue("movement_cost",
                        calculateTrvSeq(fromSequence, toSequence));
            }
            catch (NumberFormatException e) {
                // we cannot calculate movement cost if travel sequence
                // is not numeric so set it to the max
                _moca.trace("NumberFormatException raised - default to MAX MOVEMENT COST");
                rs.setDoubleValue("movement_cost", MAX_MOVEMENT_COST);
            }
            catch (ColumnNotFoundException e) {

                // the trvseq was not in the rs so we have to look up the
                // data for the location that is being evaluated
                try {

                    // Set the movement_cost according to WM
                    rs.setDoubleValue("movement_cost",
                            calculateTrvSeq(fromSequence,
                                    getLocationSequence(rs.getString("to_loc"), whId, useStoSeq)));
                }
                catch (NumberFormatException ex) {
                    // we cannot calculate movement cost if travel sequence
                    // is not numeric so set it to the max
                    _moca.trace("NumberFormatException raised - default to MAX MOVEMENT COST");
                    rs.setDoubleValue("movement_cost", MAX_MOVEMENT_COST);
                }
                catch (MocaException ex) {
                    _moca.trace("Failed to select Destination ('"
                            + rs.getString("to_loc")
                            + "') Travel Sequence! "
                            + "ERROR: " + ex.getErrorCode() + " - "
                            + e.getMessage() + ".");
                    rs.setDoubleValue("movement_cost", MAX_MOVEMENT_COST);
                }
            }
        }

        // return sorted results ascending according to wm movement_cost, this
        // will enable us to process "good" candidate locations first when we
        // make the remote call to LMS
        if (rs.containsColumn("detAisleNum"))
        {
            _moca.trace("custom order column detAisleNum exist, using existing order.");
            return rs;
        }
        else
        {
            _moca.trace("Reorder locSet with movement_cost.");
            CoreService mocaService = new CoreService();
            return (EditableResults) mocaService.sortResultSet(rs, "movement_cost");
        }

    }

    /**
     * Raises an EMS event for specified parameters.
     *
     * @param cmdString Command String
     * @param returnStatus Return Status
     * @param whId Warehouse Identifier
     */
    private void raiseEmsEvent(String cmdString, int returnStatus,
            String whId) {

        _moca.trace("Attempting to raise an EMS event for the error...");

        try {
            _moca.executeCommand(
                "  raise ems event for lm error "
                + "   where command_string = @cmd_string"
                + "     and component = 'list locations with movement cost'"
                + "     and evt_nam = 'WMD-LM-COMM-ERROR' "
                + "     and ret_status = @ret_status "
                + "     and wh_id = @wh_id ",
                new MocaArgument("cmd_string", cmdString),
                new MocaArgument("ret_status", returnStatus),
                new MocaArgument("wh_id", whId));
        }
        catch (MocaException e) {
            _moca.trace("Failed to raise the EMS event for error message! "
                + "ERROR: " + e.getErrorCode() + " - " + e.getMessage() + ".");
        }
    }

    /**
     * Retrieves the travel sequence for the given location.
     *
     * @param location Location
     * @param whId Warehouse Identifier
     * @throws MocaException
     */
    private String getLocationSequence(String location, String whId,
        Integer useStoSeq) throws MocaException {

        String sequenceColumn = null;

        if (useStoSeq.equals(1)) {
            // If a storage sequence has not been defined,
            // fall back to travel sequence.
            sequenceColumn = "decode(locmst.sto_seq, "
                + WMDConstants.STORAGE_SEQUENCE_NOT_DEFINED
                + ", locmst.trvseq, locmst.sto_seq) as sequence";
        }
        else {
            sequenceColumn = "trvseq as sequence";
        }

        // get the source travel sequence
        String cmd = "[select " + sequenceColumn
                   + "   from locmst"
                   + "  where stoloc = '" + location + "'"
                   + "    and wh_id ='" + whId + "']";

        MocaResults trvSeqRes = _moca.executeCommand(cmd);
        trvSeqRes.next();
        return trvSeqRes.getString("sequence");
    }

    /**
     * Calculate the WM movement cost by source and destination travel sequence.
     *
     * @param fromTrvSeq Source Travel Sequence
     * @param toTrvSeq Destination Travel Sequence
     * @throws NumberFormatException
     */
    private double calculateTrvSeq(String fromTrvSeq, String toTrvSeq)
            throws NumberFormatException {

        return (double) Math.abs(
            Integer.parseInt(fromTrvSeq)
                    - Integer.parseInt(toTrvSeq));
    }
    
    /**
    * Sets vehicle Type
    *
    * @param whId warehouse id
    */
   private void setVehicleType(String whId){
       String command = "";
       try{
           command = 
                "[select vehtyp "
               + "   from rftmst "
               + "  where devcod= nvl(@devcod,@@devcod)"
               + "    and wh_id = '" + whId + "'"
               + "    and rownum<2] catch(-1403)";
           MocaResults rs = _moca.executeCommand(command);
           if(rs != null && rs.next()){
           vehType = rs.getString("vehtyp");
       }
       } 
       catch (MocaException e) {
           _moca.trace("Error in fetching vehtype!");
       }
   }  

    /**
     * If configuration calls for it, reduce the number of locations to be
     * sent to LM. This is a great way to reduce execution time if LM is only
     * able to process a certain number of locations in the 500ms time limit.
     * This will only provide a performance improvement if using a remote
     * LM server, not part of the same moca instance since the most time is
     * spent sending data for thousands of location records over the wire.
     *
     * @param locationResults The full list of locations.
     * @param whId The warehouse we are in.
     * @return Top X locations from the input result set, based on config.
     */
    protected MocaResults getTopLocations(MocaResults locationResults, String whId) {

        Integer maxRows = 0;
        Policy maxRowsPolicy = getMovementCostPolicy(whId);
        if (maxRowsPolicy != null &&
            maxRowsPolicy.getRtNum1() == 1) {
            maxRows = maxRowsPolicy.getRtNum2();
        }

        if (maxRows > 0 &&
            locationResults.getRowCount() > maxRows) {
            try {

                return _moca.executeCommand(PUBLISH_TOP_ROWS,
                                            new MocaArgument("locSet", locationResults),
                                            new MocaArgument("maxRows", maxRows));
            }
            catch (MocaException e) {
                return locationResults;
            }
        }
        else {

            return locationResults;
        }
    }

    /**
     * Get the policy for movement cost max rows. Returning
     * null if the policy doesn't exist.
     *
     * @param whId The warehouse we are in.WMD-234405
     * 
     * @return The movement cost max rows policy.
     */
    protected Policy getMovementCostPolicy(String whId) {
            return null;
    }

    /**
     * For JUnit testing. Returns the policyutils instance.
     * @return The policyutils instance.
     */
    protected PolicyUtils getPolicyUtilsInstance() {
        return PolicyUtils.getInstance();
    }

    // Instance variable(s)
    private final MocaContext _moca;
    private String vehType ="AMBFK";

    // Constant(s)
    // The DUMMY machineID configured can have
    // the maxWalkDistance that match the column length of numeric index 7,3
    // in Labour Management.
    // Setting Movement Cost to a maximum 5 digit value so that if the returned
    // list is sorted then the location with the max values is at the bottom.
    protected static final int MAX_MOVEMENT_COST = 99999;

    // Using local syntax here because MocaResults/RowIterator doesn't have
    // methods for fetching whole rows to add to a new result set.
    protected static final String PUBLISH_TOP_ROWS = " publish top rows                                           \n" +
                                                     "     where rows = @maxRows                                  \n" +
                                                     "     and res = @locSet                                      \n";
}
