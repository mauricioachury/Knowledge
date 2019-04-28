<resource>
    <id>slot_location</id>
    <name>slotLocation</name>
    <description>Slot Items to Locations</description>
    <properties>
        <property name="rplnum"         type="string"  pk="true" description="rplnum"/>
        <property name="wh_id"          type="string"  description="Id of the warehouse."/>
        <property name="prtnum"         type="string"  description="Item Number."/>
        <property name="prt_client_id"  type="string"  description="Item Client ID."/>
        <property name="stoloc"         type="string"  description="Slot Location."/>
        <property name="mov_zone_id"    type="string"  description="Movement Zone ID."/>
        <property name="invsts"         type="string"  description="Inventory Status."/>
        <property name="pctflg"         type="string"  description="Percentage Flag."/>
        <property name="maxunt"         type="integer" description="Max Quantity."/>
        <property name="minunt"         type="integer" description="Min Quantity."/>
        <property name="maxloc"         type="integer" description="Max Num Locations."/>
        <property name="cmpflg"         type="integer" description="Complete Flag."/>
        <property name="rpldte"         type="date" description="Replenish Date."/>
        <property name="inc_pct_flg"    type="integer" description="Increment Percentage Flag."/>
        <property name="inc_unt"        type="integer" description="Increment Unit."/>
        <property name="rls_pct"        type="integer" description="Release Percentage."/>
        <property name="mod_usr_id"     type="string" description="Modify User ID."/>
    </properties>
    <actions>
        <action type="list"     ref="listSlotLocations"/>
        <action type="get"      ref="getSlotLocation"/>
        <action type="add"      ref="addSlotLocation"/>
        <action type="edit"     ref="editSlotLocation"/>
        <action type="delete"   ref="deleteSlotLocation"/>
        <action type="action"   ref="toggleCmpFlg"/>
    </actions>
</resource>