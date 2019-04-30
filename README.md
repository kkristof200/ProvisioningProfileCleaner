# ProvisioningProfileCleaner

Lets you easily remove existing provisioning profiles from ~Library/MobileDevice/Provisioning\ Profiles

The problem
- All the files have random name, and is hard to identify them

![Filenames](https://i.imgur.com/G4Do3z8.png)

How does this script solve the problem?
- Lists/prints all the provisioning files with the following informations
  - Filename
  - AppIDName
  - CreationDate
  - ExpirationDate
  - Name
  - TeamName
  - Entitlements:application-identifier
  - Expiration status (Valid/Invalid(expired))

- Lets you choose one by one which one to delete
  - Default behavior: only asks files, which have an invalid/expired status
  - By passing 'deleteAll': Asks to delete every file one by one

![While running](https://i.imgur.com/zRE1kdk.png)




Usage
```
# For main functionality
  sh ppc.sh
  sh ppc.sh deleteAll
  
# For printing help
  sh ppc.sh help
  OR
  sh ppc.sh man
```
