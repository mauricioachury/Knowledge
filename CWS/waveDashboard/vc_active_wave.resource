<resource>
    <id>vc_active_wave</id>
    <name>Active Wave</name>
    <description>Active waves</description>

    <properties>
        <property name="schbat" type="string" description="Wave Number." />
        <property name="ordtyp" type="string" description="Order Type." />
        <property name="cut_off" type="string" description="Cutoff time." />
        <property name="tot_ord_cnt" type="string" description="Total number of orders for the wave." />
        <property name="tot_ord_allocated" type="string" description="Total number of orders allocated." />
        <property name="tot_ord_released" type="string" description="Total number of orders released." />
        <property name="tot_ord_picked" type="string" description="Total number of orders picked." />
        <property name="tot_ord_staged" type="string" description="Total number of orders staged." />
        <property name="tot_ord_packed" type="string" description="Total number of orders packed." />
        <property name="tot_ord_loaded" type="string" description="Total number of orders loaded." />
        <property name="tot_ord_dispatched" type="string" description="Total number of orders dispatched." />
    </properties>

    <actions>
        <action type="list" ref="listActiveWaves" />
    </actions>
</resource>