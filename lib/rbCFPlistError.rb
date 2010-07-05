# -*- coding: utf-8 -*-
#
# CFFormatError implementation
#
# Author::    Christian Kruse (mailto:cjk@wwwtech.de)
# Copyright:: Copyright (c) 2010
# License::   MIT License

# general plist error. All exceptions thrown are derived from this class.
class CFPlistError < Exception
end

# Exception thrown when format errors occur
class CFFormatError < CFPlistError
end

# Exception thrown when type errors occur
class CFTypeError < CFPlistError
end

# eof
