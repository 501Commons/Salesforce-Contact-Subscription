trigger C501_CS_AccountTrigger on Account (before update, before insert) {

    public class AccountException extends Exception {}

    Set<String> accountNames = new Set<String>();
    for (Account accountUpdated :trigger.new) {
        accountNames.add(accountUpdated.Name);
    }

    List<Account> accountNamesMatching = [SELECT Id, Name FROM Account WHERE Name in :accountNames];
    if (accountNamesMatching.isEmpty()) {
        return;
    }

    for (Account accountMatching :accountNamesMatching) {
        for (Account accountUpdated :trigger.new) {
            if (trigger.isInsert) {
                if (accountMatching.Name.equalsIgnoreCase(accountUpdated.Name)) {
                    accountUpdated.addError( new AccountException('Insert Attempt - Account Name: ' + accountMatching.Name + ' already exists.'));
                }
            }
            else {
                if (accountMatching.Name.equalsIgnoreCase(accountUpdated.Name) && accountMatching.Id <> accountUpdated.Id) {
                    accountUpdated.addError( new AccountException('Update Attempt - Account Name: ' + accountMatching.Name + ' already exists.'));
                }               
            }
        }
    }
}