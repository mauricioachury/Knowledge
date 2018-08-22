Toll has putaway inefficency when they putawy double pallets, the package is the last rollout developed for resolving this issue:
Approach:
Add a trigger to 'allocate location' command to check if there are 2 pallets on the RDT and these pallets are allocated with different locations, if so try to reallocate them with same location again.
