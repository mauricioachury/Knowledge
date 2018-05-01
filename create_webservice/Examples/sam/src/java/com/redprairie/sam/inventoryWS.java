package com.redprairie.sam;
import java.io.IOException;
import java.util.Map;
import org.apache.log4j.Logger;
import java.io.UnsupportedEncodingException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.json.JSONException;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import com.mangofactory.swagger.annotations.ApiIgnore;
import com.redprairie.moca.server.webservices.custom.Action;
import com.redprairie.moca.server.webservices.custom.ActionType;
import com.redprairie.moca.servlet.Authentication;
import com.redprairie.moca.servlet.authorization.Authorization;
import com.redprairie.moca.servlet.authorization.MocaWebAuthorization;
import com.wordnik.swagger.annotations.Api;
import com.wordnik.swagger.annotations.ApiOperation;
import com.wordnik.swagger.annotations.ApiParam;
import com.redprairie.moca.MocaContext;
import com.redprairie.moca.MocaException;
import com.redprairie.moca.MocaResults;
import com.redprairie.moca.util.MocaUtils;
/**
 * This class is used to test web services.  It responds to GET and POST requests with a text message.
 * @Authorization is mandatory otherwise give 401 Unauthorized error.
 */
@Controller
@Authorization(options={MocaWebAuthorization.OPEN})
@Api(value="list_inventory", description="The operation to list inventory as web service.")
public class inventoryWS
{
    private static final Logger log = Logger.getLogger(inventoryWS.class);
    /**
     * This method is used to consume a GET HTTPRequest.
     *
     * @param request
     * @param response
     * @throws IOException
     * @throws JSONException
     */
    @ActionType(type = Action.ActionType.ACTION)
    @RequestMapping(value="list_inventory", method=RequestMethod.GET)
    @ApiOperation(value="A GET endpoint used for list inventory.")
    public void getListInventory(
            HttpServletRequest request,
            HttpServletResponse response,
            @ApiIgnore MocaContext moca,
            @RequestParam(value=STOLOC) 
            @ApiParam(name=STOLOC, value="Inventory stoloc", required=true) String stoloc) throws IOException, MocaException,
            UnsupportedEncodingException {
        response.setContentType("text/plain");
        String res = "";
        
        String cmd = "list inventory where stoloc = '" + stoloc + "'";
        log.trace("Executing ws command:" + cmd);
        MocaResults rs = moca.executeCommand(cmd);
        try {
        while(rs.next()) {
            res += rs.getString("stoloc") + ": " + rs.getString("prtnum") + ": " + rs.getString("untqty") + "\n";
        }
        }
        catch(Exception e) {
            log.trace("Exception: " +e.getMessage());
        }
        
        response.getWriter().write(res);
        response.getWriter().flush();
        response.getWriter().close();
    }
    /**
     * This method is used to consume a POST HTTPRequest.
     *
     * @param request
     * @param response
     * @param argMap
     * @throws IOException
     * @throws JSONException
     */
    @ActionType(type = Action.ActionType.ACTION)
    @RequestMapping(value="list_inventory", method=RequestMethod.POST)
    @ApiOperation(value="A POST endpoint used list inventory.")
    public void postListInventory(
            HttpServletRequest request,
            HttpServletResponse response,
            @ApiIgnore MocaContext moca,
            @RequestParam(value=STOLOC) 
            @ApiParam(name=STOLOC, value="Inventory stoloc", required=true) String stoloc) throws IOException, MocaException,
            UnsupportedEncodingException {
        response.setContentType("text/plain");
        String res = "";
        
        String cmd = "list inventory where stoloc = '" + stoloc + "'";
        log.trace("Executing ws command with Post:" + cmd);
        MocaResults rs = moca.executeCommand(cmd);
        try {
        while(rs.next()) {
            res += rs.getString("stoloc") + ": " + rs.getString("lodnum") + ": " + rs.getString("prtnum") + ": " + rs.getString("untqty") + "\n";
        }
        }
        catch(Exception e) {
            log.trace("Exception: " +e.getMessage());
        }
        response.getWriter().write(res);
        response.getWriter().flush();
        response.getWriter().close();
    }
    
    /**
     * This method is used to consume a POST HTTPRequest.
     *
     * @param request
     * @param response
     * @param argMap
     * @throws IOException
     * @throws JSONException
     */
    @ActionType(type = Action.ActionType.ACTION)
    @RequestMapping(value="remove_inventory", method=RequestMethod.POST)
    @ApiOperation(value="A POST endpoint used list inventory.")
    public void postRemoveInventory(
            HttpServletRequest request,
            HttpServletResponse response,
            @ApiIgnore MocaContext moca,
            @RequestParam(value=STOLOC) 
            @ApiParam(name=STOLOC, value="Inventory stoloc", required=true) String stoloc) throws IOException, MocaException,
            UnsupportedEncodingException {
        response.setContentType("text/plain");
        String res = "";
        
        String cmd = "[select distinct lodnum, wh_id from inventory_view iv where iv.stoloc = '" + stoloc + "']" +
                     "| " +
                     "move inventory " +
                     " where lodnum = @lodnum " +
                     "   and dstloc = 'PERM-ADJ-LOC'" +
                     "   and wh_id = @wh_id ";
        log.warn("Executing ws command with Post:" + cmd);
        
        try {
            MocaResults rs = moca.executeCommand(cmd);
            while(rs.next()) {
                res += rs.getString("dstloc") + ": " + rs.getString("lodnum") + "\n";
            }
        }
        catch(Exception e) {
            e.printStackTrace();
            log.error("Exception: " +e.getMessage());
            throw new MocaException(-1403);
        }
        response.getWriter().write(res);
        response.getWriter().flush();
        response.getWriter().close();
    }
    private final static String STOLOC = "stoloc";
}