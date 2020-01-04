<resource>
    <id>vc_active_wave_detail</id>
    <name>Active Wave Detail</name>
    <description>Active wave Detail</description>

    <properties>
        <property name="schbat" type="string" description="Wave Number" />
        <property name="ordtyp" type="string" description="Order Type" />
        <property name="cut_off" type="string" description="Cut Off" />
        <property name="stgloc" type="string" description="Stage Location" />
        <property name="bc" type="string" description="Bill to Customer" />
        <property name="bc" type="string" description="Bill to Customer" />
        <property name="tot_ord_cnt" type="string" description="Total number of orders for the wave." />
        <property name="tot_ord_allocated" type="string" description="Total number of orders allocated." />
        <property name="tot_ord_picked" type="string" description="Total number of orders picked." />
        <property name="tot_ord_staged" type="string" description="Total number of orders staged." />
        <property name="tot_ord_packed" type="string" description="Total number of orders packed." />
    </properties>

    <actions>
        <action type="list" ref="listActiveWaveDetail" />
    </actions>
</resource>