Readme
1. Put the build_ws.xml into LES folder and type 'ant -f build_ws.xml' to build, which will build a sam.war into webdeploy folder.
2. Put the sam folder into the LES/ws folder.

Test:
1. After build the war into LES/webdeploy folder, restart the moca.
2. Go to browser and request key by:"http://192.168.0.108:4650/ws/auth/login?usr_id=SUPER&password=SUPER"
3. Use F12 to open debug window, and go to network tab find Cookie like:
MOCA-WS-SESSIONKEY=%3Buid%3DSUPER%7Csid%3D068750d7-07fa-4297-ab1f-a23ee0712f45%7Cdt%3Djgm3gmc2%7Csec%3DALL%3Bb2flsNIoxxb__9QJmJwB3Wy0.2
4. Add Cookie into postman, and then test uri like:
http://192.168.0.108:4650/ws/sam/list_inventory?stoloc=1PALA04
it will return result like:
1PALA04: L000000007PW: ANTACID_B: 100
1PALA04: LPNB002: ANTACID_B: 100
1PALA04: LPNB003: ANTACID_B: 100
