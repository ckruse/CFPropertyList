# -*- coding: utf-8 -*-
#
# CFFormatError implementation
#
# Author::    Christian Kruse (mailto:cjk@wwwtech.de)
# Copyright:: Copyright (c) 2010
# License::   MIT License

class CFPlistError < Exception
end

# Exception thrown when format errors occur
class CFFormatError < CFPlistError
end

class CFTypeError < CFPlistError
end

# eof
