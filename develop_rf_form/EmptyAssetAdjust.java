/*
 *  $URL$
 *  $Revision$
 *  $Author$
 *  $Date: 2013-11-21
 *
 *  $Copyright-Start$
 *
 *  Copyright (c) 2008
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
package com.redprairie.les.formlogic;

import com.redprairie.moca.MocaException;
import com.redprairie.moca.MocaResults;
import com.redprairie.moca.NotFoundException;
import com.redprairie.mtf.MtfConstants;
import com.redprairie.mtf.exceptions.XFailedRequest;
import com.redprairie.mtf.exceptions.XFormAlreadyOnStack;
import com.redprairie.mtf.exceptions.XInvalidArg;
import com.redprairie.mtf.exceptions.XInvalidRequest;
import com.redprairie.mtf.exceptions.XInvalidState;
import com.redprairie.mtf.foundation.presentation.ACommand;
import com.redprairie.mtf.foundation.presentation.AFormLogic;
import com.redprairie.mtf.foundation.presentation.CWidgetActionAdapter;
import com.redprairie.mtf.foundation.presentation.IContainer;
import com.redprairie.mtf.foundation.presentation.IDisplay;
import com.redprairie.mtf.foundation.presentation.IEntryField;
import com.redprairie.mtf.foundation.presentation.IForm;
import com.redprairie.mtf.foundation.presentation.IFormSegment;
import com.redprairie.mtf.foundation.presentation.IInteractiveWidget;
import com.redprairie.mtf.foundation.presentation.IWidgetActionValidator;
import com.redprairie.wmd.WMDConstants;
import com.redprairie.les.JMSConstants;
import org.apache.log4j.Logger;

/**
 * This class is responsible for receiving and shipping empty Handling Units.
 * This class is accessible from Tools Menu.
 *
 * <b>
 *
 * <pre>
 * Copyright (c) 2018 Ascension Logistics
 * All Rights Reserved
 * </pre>
 *
 * </b>
 *
 * @author Sam Ni
 * @version Revision: $
 */
public class EmptyAssetAdjust extends AFormLogic {

    /**
     * Instance Variables.
     */
    private IWidgetActionValidator actEmptyAssetAdjust;
    private IFormSegment segDef;
    public IEntryField  efFrmAdrId;
    public IEntryField  efToAdrId;
    private IEntryField efBldgId;
    private IEntryField efAssetTyp;
    public IEntryField  efAssetStat;
    private IEntryField efClientId;
    private IEntryField efOnHandQty;
    private IEntryField efIsInbMode;
    private IWidgetActionValidator actBldgId;
    private IWidgetActionValidator actAssetTyp;
    private IWidgetActionValidator actAssetStat;
    private IWidgetActionValidator actOnHandQty;
    
    private ACommand cmdFkeyBack;
    
    private static final Logger log = Logger.getLogger(EmptyAssetAdjust.class);

    /**
     * Constructor.
     */
    public EmptyAssetAdjust(final IDisplay _display) throws Exception {

        super(_display);
        // Create form and default segment
        frmMain = display.createForm("EMPTY_ASSET_ADJUST");
        actEmptyAssetAdjust = this.new EmptyAssetAdjustActions();
        frmMain.addWidgetAction(actEmptyAssetAdjust);
        
        // Create default segment on the form.
        segDef = frmMain.createSegment("segDef", false);

        efFrmAdrId = segDef.createEntryField("frm_adr_id", "lblFrmAdrId");
        efFrmAdrId.setEnabled(false);
        efFrmAdrId.setVisible(false);
        efFrmAdrId.setEntryRequired(false);
        
        efToAdrId = segDef.createEntryField("to_adr_id", "lblToAdrId");
        efToAdrId.setEnabled(false);
        efToAdrId.setVisible(false);
        efToAdrId.setEntryRequired(false);
        
        efBldgId = segDef.createEntryField("bldg_id", "lblBldg");
        efBldgId.setEnabled(true);
        efBldgId.setVisible(true);
        efBldgId.setEntryRequired(true);
        actBldgId = this.new BldgIdActions();
        efBldgId.addWidgetAction(actBldgId);

        efAssetTyp = segDef.createEntryField("asset_typ", "lblAssetTyp");
        efAssetTyp.setEnabled(true);
        efAssetTyp.setVisible(true);
        efAssetTyp.setEntryRequired(true);
        actAssetTyp = this.new AssetTypActions();
        efAssetTyp.addWidgetAction(actAssetTyp);

        efAssetStat = segDef.createEntryField("asset_stat", "lblAstSts");
        efAssetStat.setEnabled(true);
        efAssetStat.setVisible(true);
        efAssetStat.setEntryRequired(true);
        actAssetStat = this.new AssetStatActions();
        efAssetStat.addWidgetAction(actAssetStat);
        
        efOnHandQty = segDef.createEntryField("on_hand_qty", "lblQty");
        efOnHandQty.setEnabled(true);
        efOnHandQty.setVisible(true);
        efOnHandQty.setEntryRequired(true);
        actOnHandQty = this.new OnHandQtyActions();
        efOnHandQty.addWidgetAction(actOnHandQty);
        
        efClientId = segDef.createEntryField("client_id", "lblClientId");
        efClientId.setVisible(false);

        efIsInbMode = segDef.createEntryField("is_inb_mode");
        efIsInbMode.setVisible(false);
        efIsInbMode.setText("1");
        
        // and then, define the form level "Back" command.
        frmMain.unbind(frmMain.getCancelCommand());
        cmdFkeyBack = this.new FkeyBackCommand();
        cmdFkeyBack.setVisible(false);
        frmMain.bind(cmdFkeyBack);
        cmdFkeyBack.bind(MtfConstants.VK_FKEY_BACK);

    }

    /**
     * Display and run the form 
     * @throws XFormAlreadyOnStack 
     * @throws XFailedRequest 
     * @throws XInvalidArg 
     * @throws XInvalidRequest 
     * @throws XInvalidState 
     */
    public final void run() throws XInvalidState, XInvalidRequest, XInvalidArg, XFailedRequest, XFormAlreadyOnStack {

        log.trace("TOOLS_MENU.exec_parm:" + display.getVariable("TOOLS_MENU.exec_parm"));
        if ("INB".equals(display.getVariable("TOOLS_MENU.exec_parm")))
        {
            log.trace("set title with ttlEmptyAssetAdjustInb.");
            frmMain.setTitle(session.getMlsCatalogEntry("ttlEmptyAssetAdjustInb"));
            efToAdrId.setEnabled(false);
            efToAdrId.setVisible(true);
            efToAdrId.setEntryRequired(false);
            efFrmAdrId.setEnabled(false);
            efFrmAdrId.setVisible(false);
            efFrmAdrId.setEntryRequired(false);
            efIsInbMode.setText("1");
        }
        else {
            log.trace("set title with ttlEmptyAssetAdjustOub.");
            frmMain.setTitle(session.getMlsCatalogEntry("ttlEmptyAssetAdjustOub"));
            efFrmAdrId.setEnabled(false);
            efFrmAdrId.setVisible(true);
            efFrmAdrId.setEntryRequired(false);
            efToAdrId.setEnabled(false);
            efToAdrId.setVisible(false);
            efToAdrId.setEntryRequired(false);
            efIsInbMode.setText("0");
        }
        frmMain.interact();
    }

    /**
     * Defines extended ACommand for FkeyBack.
     **/
    private class FkeyBackCommand extends ACommand {
        /**
         * Prime constructor.
         */
        public FkeyBackCommand() {
            super("cmdFkeyBack", "FkeyBack",
                    MtfConstants.FKEY_BACK_CAPTION, '1');
        }

        /**
         * Performs the actions for the function key.
         *
         * @param _container
         *           Container
         * @throws XFormAlreadyOnStack 
         * @throws ClassNotFoundException 
         * @throws NullPointerException 
         * @throws MocaException 
         * @throws XFailedRequest 
         * @throws XInvalidArg 
         * @throws XInvalidRequest 
         * @throws XInvalidState 
         */
        public void execute(final IContainer _container) throws XFormAlreadyOnStack, NullPointerException, ClassNotFoundException, XInvalidState, XInvalidRequest, XInvalidArg, XFailedRequest, MocaException {

            frmMain.clearForm();
            frmMain.formBack();
        }

        private static final long serialVersionUID = 0L;
    }

    /**
     * The class contains entry/exit actions for frmMain.
     */
    private class EmptyAssetAdjustActions extends CWidgetActionAdapter {

        /**
         * On Form entry.
         */
        public boolean onFormEntry(final IForm _frm) throws Exception {

            autoPopulateDefaults();
            
            return true;
        }

        /**
         * On Form Exit. 
         */
        public boolean onFormExit(final IForm _frm) throws Exception {

            return true;
        }
    }

    /**
     * The class contains entry/exit actions for efBldgId.
     */
    private class BldgIdActions extends CWidgetActionAdapter {

        @Override
        public boolean onFieldExit(final IInteractiveWidget _ef) throws Exception {
            return true;
        }
    }

    /**
     * The class contains entry/exit actions for efAssetTyp.
     */
    private class AssetTypActions extends CWidgetActionAdapter {

        @Override
        public boolean onFieldExit(final IInteractiveWidget _ef) throws Exception {
            // Checking Whether to Create New Asset or Not

            return true;
        }
    }

    /**
     * The class contains entry/exit actions for efAssetStat.
     */
    private class AssetStatActions extends CWidgetActionAdapter {

        @Override
        public boolean onFieldExit(final IInteractiveWidget _ef) throws Exception {

            if (!validateData())
            {
                return false;
            }
            //LoadOnHandQty();

            return true;
        }
    }
    /**
     * The class contains entry/exit actions for efUntqty.
     */
    private class OnHandQtyActions extends CWidgetActionAdapter {

        @Override
        public boolean onFieldExit(final IInteractiveWidget _ef) throws Exception {

            if (validateData())
            {
                if (updateOnHandQty())
                {
                    if (efIsInbMode.getText().equals("1"))
                    {
                        frmMain.promptMessageAnyKey(JMSConstants.HU_QTY_RCV_SUCCESS);
                    }
                    else
                    {
                        frmMain.promptMessageAnyKey(JMSConstants.HU_QTY_SHP_SUCCESS);
                    }
                    resetForm();
                }
                return true;
            }
            else
            {
                return false;
            }
        }
        
        private boolean updateOnHandQty()
        {
            String adr_id = efIsInbMode.getText().equals("1") ? efFrmAdrId.getText().trim() : efToAdrId.getText().trim();
            String bldg_id = efBldgId.getText();
            String asset_typ = efAssetTyp.getText();
            String asset_stat = efAssetStat.getText();
            String on_hand_qty = efOnHandQty.getText();
            
            if (efIsInbMode.getText().equals("1"))
            {
                //Inbound mode, increase on hand qty.
                try {
                    MocaResults rs = session.executeCommand(
                            " [select adrmst.adr_id cur_adr_id " +
                            "    from adrmst, wh " +
                            "   where adrmst.adr_id = wh.adr_id " +
                            "     and wh.wh_id = '" + display.getVariable("global.wh_id") + "']" +
                            "| " +
                            "[select 'x' " +
                            "   from non_ser_asset " +
                            "    where src_adr_id = @cur_adr_id" +
                            "      and adr_id = @cur_adr_id " +
                            "      and bldg_id = '" + bldg_id + "'" +
                            "      and asset_typ = '" + asset_typ + "'" +
                            "      and asset_stat = '" + asset_stat + "'] catch(-1403)" +
                            "|" +
                            "if (@? = 0)" +
                            "{" +
                            "     [update non_ser_asset" +
                            "         set on_hand_qty += " + on_hand_qty + "," +
                            "             last_upd_user_id = '" + display.getVariable("global.usr_id") + "'," +
                            "             last_upd_dt = sysdate " +
                            "       where adr_id = @cur_adr_id " +
                            "         and src_adr_id = @cur_adr_id " +
                            "         and bldg_id = '" + bldg_id + "'" +
                            "         and asset_typ = '" + asset_typ + "'" +
                            "         and asset_stat = '" + asset_stat + "']" +
                            "}" +
                            "else" +
                            "{" +
                            "    [insert into non_ser_asset (bldg_id, asset_typ, asset_stat, on_hand_qty, client_id, src_adr_id, adr_id, ins_dt, last_upd_dt, ins_user_id, last_upd_user_id) values('" +
                                   bldg_id + "','" + asset_typ + "','" + asset_stat + "', " + on_hand_qty + ",'----', @cur_adr_id, @cur_adr_id,sysdate,"  + "sysdate,'" + display.getVariable("global.usr_id") + "','" + display.getVariable("global.usr_id") + "')]" +
                            "}");
                }
                catch (Exception e) {
                    log.trace("Exception:" + e.getMessage());
                    return false;
                }
            }
            else
            {
                //Outbound mode, reduce on hand qty.
                try {
                    MocaResults rs = session.executeCommand(
                            " [select adrmst.adr_id cur_adr_id " +
                            "    from adrmst, wh " +
                            "   where adrmst.adr_id = wh.adr_id " +
                            "     and wh.wh_id = '" + display.getVariable("global.wh_id") + "']" +
                            "|" +
                            "[select 'x' " +
                            "   from non_ser_asset " +
                            "  where on_hand_qty <= " + on_hand_qty +
                            "    and adr_id = @cur_adr_id " +
                            "    and src_adr_id = @cur_adr_id " +
                            "    and bldg_id = '" + bldg_id + "'" +
                            "    and asset_typ = '" + asset_typ + "'" +
                            "    and asset_stat = '" + asset_stat + "']catch(-1403) " +
                            "| " +
                            "if (@? = -1403) " +
                            "{ " +
                            "     [update non_ser_asset" +
                            "         set on_hand_qty -= " + on_hand_qty + "," +
                            "             last_upd_user_id = '" + display.getVariable("global.usr_id") + "'," +
                            "             last_upd_dt = sysdate " +
                            "       where adr_id = @cur_adr_id " +
                            "         and src_adr_id = @cur_adr_id " +
                            "         and bldg_id = '" + bldg_id + "'" +
                            "         and asset_typ = '" + asset_typ + "'" +
                            "         and asset_stat = '" + asset_stat + "']" +
                            "} " +
                            "else " +
                            "{ " +
                            "   [delete from non_ser_asset " +
                            "     where adr_id = @cur_adr_id " +
                            "       and src_adr_id = @cur_adr_id " +
                            "       and bldg_id = '" + bldg_id + "'" +
                            "       and asset_typ = '" + asset_typ + "'" +
                            "       and asset_stat = '" + asset_stat + "']" +
                            "}");
                }
                catch (Exception e) {
                    log.trace("Exception:" + e.getMessage());
                    return false;
                }
            }
            return true;
        }
        
        private void resetForm() throws Exception
        {
            efBldgId.setText("");
            efAssetTyp.setText("");
            efAssetStat.setText("");
            efOnHandQty.setText("");
            autoPopulateDefaults();
            efBldgId.setFocus();
        }
    }
    
    /**
     * This method is used to auto populate quantity on hand.
     */
    public boolean LoadOnHandQty() throws Exception {
        
        String adr_id = efIsInbMode.getText().equals("1") ? efToAdrId.getText().trim() : efFrmAdrId.getText().trim();
        if (adr_id.length() > 0 &&
            efBldgId.getText().trim().length() > 0 &&
            efAssetTyp.getText().trim().length() > 0 &&
            efAssetStat.getText().trim().length() > 0)
        {
            try {
                MocaResults rs = session.executeCommand(
                        "[select on_hand_qty " +
                        "   from non_ser_asset " +
                        "    where src_adr_id = '" + adr_id + "'" +
                        "      and adr_id = '" + adr_id + "'" +
                        "      and bldg_id = '" + efBldgId.getText() + "'" +
                        "      and asset_typ = '" + efAssetTyp.getText() + "'" +
                        "      and asset_stat = '" + efAssetStat.getText() + "']");

                    rs.next();
                    efOnHandQty.setText(rs.getString("on_hand_qty"));
                    return true;
            }
            catch (NotFoundException nfEx) {
            }
        }
        return false;
    }
    
    /* This function auto populate some default values
     * 
     */
    private void autoPopulateDefaults() throws Exception {
//        try {
//            MocaResults rs = session.executeCommand(
//                    "[select a.adr_id " +
//                    "   from adrmst a," +
//                    "        wh " +
//                    "    where a.adr_id = wh.adr_id " +
//                    "      and wh.wh_id = '" + display.getVariable("global.wh_id") + "']");
//
//                rs.next();
//                
//                if (efIsInbMode.getText().equals("1")) {
//                    efFrmAdrId.setText(rs.getString("adr_id"));
//                }
//                else {
//                    efToAdrId.setText(rs.getString("adr_id"));
//                }
//        }
//        catch (NotFoundException nfEx) {
//        }
        
        //Assumption is that any building has picking area defined.
        try {
            MocaResults rs = session.executeCommand(
                    "[select bldg_id " +
                    "   from alloc_search_path_view " +
                    "    where wh_id = '" + display.getVariable("global.wh_id") + "']");

                rs.next();
                efBldgId.setText(rs.getString("bldg_id"));
                
                rs = session.executeCommand(
                " [select adrmst.adr_id cur_adr_id " +
                "    from adrmst, wh " +
                "   where adrmst.adr_id = wh.adr_id " +
                "     and wh.wh_id = '" + display.getVariable("global.wh_id") + "']");
                
                rs.next();
                if (efIsInbMode.getText().equals("1")) {
                    efToAdrId.setText(rs.getString("cur_adr_id"));
                }
                else {
                    efFrmAdrId.setText(rs.getString("cur_adr_id"));
                }
        }
        catch (NotFoundException nfEx) {
        }
    }
    
    private boolean validateData()
    {
        int scanQty = 0;
        try {

            scanQty = Integer.parseInt(efOnHandQty.getText());

            if (scanQty < 0) {
                return false;
            }
        }
        catch (NumberFormatException formatEx) {
            return false;
        }

        if (!efIsInbMode.getText().equals("1"))
        {
            String adr_id = efFrmAdrId.getText().trim();
            try {
                MocaResults rs = session.executeCommand(
                        "[select 'x' " +
                        "   from non_ser_asset " +
                        "    where adr_id = '" + adr_id + "'" +
                        "      and src_adr_id = '" + adr_id + "'" +
                        "      and bldg_id = '" + efBldgId.getText() + "'" +
                        "      and asset_typ = '" + efAssetTyp.getText() + "'" +
                        "      and asset_stat = '" + efAssetStat.getText() + "']");

            }
            catch (Exception nfEx) {
                frmMain.promptMessageAnyKey(JMSConstants.SHP_HU_NOT_EXISTS);
                return false;
            }
            
            try {
                MocaResults rs = session.executeCommand(
                        "list non serialized assets " +
                        "    where adr_id = '" + adr_id + "'" +
                        "      and src_adr_id = '" + adr_id + "'" +
                        "      and bldg_id = '" + efBldgId.getText() + "'" +
                        "      and asset_typ = '" + efAssetTyp.getText() + "'" +
                        "      and asset_stat = '" + efAssetStat.getText() + "'" +
                        "| " +
                        "if (@empty_asst_qty < " + efOnHandQty.getText() + ")" +
                        "{ " +
                        "    set return status where status = -1403 " +
                        "}");

            }
            catch (Exception nfEx) {
                frmMain.promptMessageAnyKey(JMSConstants.SHP_HU_OVER_QTY);
                return false;
            }
        }
        return true;
    }
}
