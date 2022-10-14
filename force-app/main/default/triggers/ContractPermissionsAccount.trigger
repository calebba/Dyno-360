trigger ContractPermissionsAccount on Account (after insert, after update) {

    ContractPermissionsClass.CreatePermissions(Trigger.newMap.keyset()); 

}