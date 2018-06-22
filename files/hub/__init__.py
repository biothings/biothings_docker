import re
__gitversion__ = "$Id$"
__version__ = re.sub("((\$Id$)|(\$Id\$))","\\3",__gitversion__)
