<resource>

  <id>Vc_UnprocessedOrders</id>

  <name>Cust-Un-Processed-Orders</name>

  <description>Custom un processed orders</description>

  <properties>  

    <property name="ordnum"  type="string" description="ordnum" pk="false"/>

    <property name="ordtyp"  type="string" description="Order Type" pk="false" />

    <property name="totalUOM"  type="int" description="HTotal UOM Quantity" pk="false" />

    <property name="PalletCnt"  type="int" description="No Of pallets" pk="false" />

    <property name="CassesonPallet"  type="int" description="Pallet cases" pk="false" />

    <property name="OtherUOM"  type="int" description="Other UOM Quantity" pk="false" />

    <property name="stcust"  type="string" description="Ship To Customer" pk="false" />

    <property name="grswgt"  type="int" description="Weight" pk="false" />

    <property name="Cube"  type="int" description="Volume" pk="false" />

    <property name="dte"  type="string" description="Depature Date" pk="false" />

    <property name="Schbat"  type="string" description="Schedule batch" pk="false" />

  </properties>

  <actions>

    <action type="list" ref="Vc_UnprocessedOrders"/>

  </actions>

</resource>
