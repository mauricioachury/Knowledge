import mock_catalyst as mc #@UnusedImport
from main import main #@UnresolvedImport

try:
    main()
except mc.EndOfApplication as err:
    print('Application ended')

