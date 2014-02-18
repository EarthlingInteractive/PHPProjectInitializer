import everything from 'http://ns.nuke24.net/Schema/'
import everything from 'http://ns.nuke24.net/Schema/DataTypeTranslation/'
import everything from 'http://ns.nuke24.net/Schema/Application/'
import 'http://ns.nuke24.net/Schema/RDB/isAutoIncremented'
import 'http://ns.nuke24.net/Schema/RDB/isSelfKeyed'
import 'http://www.w3.org/2000/01/rdf-schema#isSubclassOf' as 'extends'

class 'integer' :
        SQL type @ "INT" :
        PHP type @ "int" : JSON type @ "number"
class 'unsigned integer' : extends(integer) :
	SQL type @ "INT UNSIGNED" : regex @ "\\d+"
class 'boolean' :
        SQL type @ "BOOLEAN" :
        PHP type @ "bool" : JSON type @ "boolean"
class 'string' :
        SQL type @ "VARCHAR(127)" :
        PHP type @ "string" : JSON type @ "string"
class 'normal ID' : extends(unsigned integer)
class 'entity ID' : extends(unsigned integer) : SQL type @ "BIGINT"
class 'code' : extends(string) : SQL type @ "CHAR(4)" : regex @ "[A-Za-z0-9 _-]{1,4}"
class 'text' : extends(string) : SQL type @ "TEXT"
class 'hash' : extends(string) : regex @ "[A-Fa-f0-9]{40}" : comment @ "Hex-encoded SHA-1 of something (40 bytes)"
class 'e-mail address' : extends(string)
class 'URI' : extends(string)

field modifier 'AIPK' = normal ID : is auto-incremented : key(primary)
field modifier 'SRC' = has a database table : has a REST service

class 'user' : has a database table {
	ID : entity ID : key(primary)
	username : string
	passhash : hash
	e-mail address : e-mail address
}

class 'organization' : SRC {
	ID : entity ID : key(primary)
	name : string
}

class 'user organization attachment' : SRC : self-keyed {
	user : reference(user) {
		ID = user ID
	}
	organization : reference(organization) {
		ID = organization ID
	}
}
