{
	"description": "{#projectName}",
	"repositories": [
		{
			"type": "vcs",
			"url": "http://robert.earthit.com/~stevens/git/EarthIT/PHPCommon.git"
		}
	],
	"require": {
		"php": ">=5.2.0",
		"ryprop/nife": "~0.0.1",
		"earthit/php-common": "~0.0.1",
		"doctrine/dbal": "~2.4.0"
	},
	"autoload": {
		"psr-0": {
			"{#projectNamespace}_": "lib/",
			"EarthIT_": "lib/"
		}
	}
}
