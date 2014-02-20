<?php

class {#phpNamespace}_Registry extends EarthIT_Registry
{
	public function getDbAdapter() {
		if( $this->dbAdapter === null ) {
			$this->dbAdapter = Doctrine_DBAL_DriverManager::getConnection( $this->getConfig('dbc') );
		}
		return $this->dbAdapter;
	}

	public function getDbNamer() {
		return new EarthIT_DBC_PostgresNamer();
	}
		
	public function getSchema() {
		return require {#phpNamespace}_ROOT_DIR.'/schema/schema.php';
	}
}
