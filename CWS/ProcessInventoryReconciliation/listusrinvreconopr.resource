<resource>
<id>listusrinvreconopr</id>
<name>Usr Inventory Reconciliation</name>
<description>Inventory Reconciliation Operations.</description>

<properties>
<property name="dept_cod" type="string" description="SAP Cost Center "/>
<property name="lngdsc" type="string" description="SAP Cost Center Description"/>
<property name="uc_client" type="string" description="Client_id"/>
<property name="wh_id" type="string" description="Warehouse Id"/>
</properties>

<actions>
<action type="list" ref="listusrinvreconopr"/>
<action type="action" ref="processInventoryReconciliation"/>
</actions>

</resource>