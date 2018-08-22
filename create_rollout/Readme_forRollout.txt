How to build RP rollouts with ALx tools?

 
Requirements:

    SVN 1.7 - command prompt
    JAVA 7 (1.7.xxx)
    BuildRollout.jar

 
Links

    to zip with tools
    main folder in SharePoint

 
Procedure:

    Create an "artifact" # in TeamForge under the correct customer Planning Folder.
    SVN checkout the correct project to work under...
        Please notice the tree structure path and try to keep it consistent.
        Main Services foler:  https://ascensionlogistics.svn.cloudforge.com/alxsuite/services
        Customer:  https://ascensionlogistics.svn.cloudforge.com/alxsuite/services/<CustomerName>/dev/wms/les
        Dev - RP Structure:  https://ascensionlogistics.svn.cloudforge.com/alxsuite/services/BuySeasons/dev/wms/les
        Special folders under LES to add:
            testing - add transactions, scripts, etc.. to be shared for testing
            rollout - save the final delivered (.zip) rollout given to the customer
                add and commit the BuildRollout.jar for your team under there...
    SVN commit code
        Copy the code to the correct location as you will in the $LESDIR structure
            db/data/load/base etc....
            src/cmdsrc etc....
        Commit using the TeamForge artifact #, example:
        [artf1234] - changes for XYX....
    Build the rollout
        Go to you ALx - $LESDIR/rollout folder where BuildRollout.jar should be added.
        Execute the script to build the rollout, example;
        java -jar BuildRollout.jar -d https://ascensionlogistics.svn.cloudforge.com/alxsuite/ -u <username> -w <password -m services/BuySeasons/dev/wms/les -t artf92023 -r BSI-2015-001-SingleUnitPick
        Check the automated rollout for any errors.
        

Use below command to build rollout as example:
java -jar BuildRollout.jar -d https://ascensionlogistics.svn.cloudforge.com/alxsuite/ -u sni -w cloudforge,16 -m services/JMS/2017.2/LES -t artf153999,artf152302 -r JMS-RF-SMART-PICK-03